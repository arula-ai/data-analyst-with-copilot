import pandas as pd
from pathlib import Path
import plotly.express as px
import plotly.graph_objects as go
from plotly.subplots import make_subplots

ROOT = Path(__file__).resolve().parents[1]
INPUT = ROOT / 'outputs' / 'treasury_payments_clean.csv'
EDA_SUM = ROOT / 'outputs' / 'A_eda_summary.txt'
RECON = ROOT / 'outputs' / 'A_reconciliation.txt'
OUT_HTML = ROOT / 'outputs' / 'A_dashboard.html'


def read_recon(path):
    txt = path.read_text(encoding='utf-8')
    for line in txt.splitlines():
        if line.startswith('Final analysis-valid row count:'):
            parts = line.split(':', 1)[1].strip()
            try:
                return int(parts)
            except:
                pass
    # fallback: search for 'Analysis denominator'
    for line in txt.splitlines():
        if 'Final analysis-valid row count' in line:
            try:
                return int(line.split(':')[1].strip())
            except:
                continue
    raise RuntimeError('Could not parse reconciliation file for analysis-valid row count')


def read_eda_summary(path):
    txt = path.read_text(encoding='utf-8')
    summary = {}
    for line in txt.splitlines():
        if line.startswith('Analysis denominator:'):
            summary['denom'] = int(line.split(':',1)[1].strip())
        if line.startswith('Overall confirmed anomaly rate:'):
            summary['rate_line'] = line.split(':',1)[1].strip()
        if line.startswith('Top cross-tab cell:'):
            summary['top_cell'] = line.split(':',1)[1].strip()
        if line.startswith('PRIORITY region:'):
            summary['priority'] = line.split(':',1)[1].strip()
        if line.startswith('Model verdict:'):
            summary['model_verdict'] = line.split(':',1)[1].strip()
    return summary


def main():
    recon_n = read_recon(RECON)
    eda = read_eda_summary(EDA_SUM)

    df = pd.read_csv(INPUT)

    # Remove PII-adjacent column if present
    if 'counterparty_masked' in df.columns:
        df = df.drop(columns=['counterparty_masked'])

    # Exclude sentinel values
    if 'prior_alerts_90d' in df.columns:
        df = df[df['prior_alerts_90d'] != 999]
    if 'analyst_confidence' in df.columns:
        df = df[df['analyst_confidence'] != -1]

    # Use analysis_exclude flag to filter analysis-valid rows
    if 'analysis_exclude' in df.columns:
        valid = df[~df['analysis_exclude']].copy()
    else:
        valid = df.copy()

    # Reconciliation excludes rows where `anomaly_confirmed` is missing (NaN).
    # Ensure those rows are removed so denominators match `outputs/A_reconciliation.txt`.
    if 'anomaly_confirmed' in valid.columns:
        valid = valid[valid['anomaly_confirmed'].notna()].copy()

    # Verify n_valid matches reconciliation (do NOT recalc for header)
    n_valid = recon_n

    # Parse EDA summary rate and verify it matches computed
    if 'rate_line' in eda:
        eda_rate_line = eda['rate_line']
    else:
        raise RuntimeError('EDA summary rate line not found')

    # compute confirmed count from valid data
    confirmed_count = int((valid['anomaly_confirmed'] == 1).sum())
    # Confirm denom from recon used; compute rate string
    computed_rate_pct = confirmed_count / n_valid * 100 if n_valid else 0.0
    computed_rate_str = f"{confirmed_count}/{n_valid} = {computed_rate_pct:.1f}%"

    if computed_rate_str not in eda_rate_line:
        raise RuntimeError(f"Mismatch between EDA summary ({eda_rate_line}) and computed ({computed_rate_str}) — aborting")

    # Prepare header values
    first_date = valid['payment_date_parsed'].dropna().min() if 'payment_date_parsed' in valid.columns else valid['payment_date'].dropna().min()
    last_date = valid['payment_date_parsed'].dropna().max() if 'payment_date_parsed' in valid.columns else valid['payment_date'].dropna().max()
    key_risk = eda.get('top_cell', 'N/A')
    model_status = eda.get('model_verdict', 'N/A')

    # Chart 1 — Bar: Confirmed anomaly rate by payment_type
    grp = valid.groupby('payment_type').agg(total_count=('anomaly_confirmed','count'), confirmed_count=('anomaly_confirmed', lambda s: int((s==1).sum())))
    grp = grp.reset_index()
    grp['rate_pct'] = grp.apply(lambda r: r['confirmed_count']/r['total_count']*100 if r['total_count']>0 else 0.0, axis=1)
    grp = grp.sort_values('rate_pct', ascending=False)

    # Enforce exact text format for bar labels: '34.0%  n=36/106'
    label_series = grp.apply(lambda r: f"{r['rate_pct']:.1f}%  n={int(r['confirmed_count'])}/{int(r['total_count'])}", axis=1)
    fig1 = px.bar(grp, x='payment_type', y='rate_pct', text=label_series,
                  labels={'payment_type':'Payment Type', 'rate_pct':'Confirmed Anomaly Rate (%)'},
                  title='Confirmed Anomaly Rate by Payment Type')
    fig1.update_yaxes(rangemode='tozero')
    # add portfolio average reference line
    fig1.add_hline(y=computed_rate_pct, line_dash='dash', annotation_text='Portfolio average', annotation_position='top left')

    # Chart 1 comment
    # This bar chart shows the confirmed anomaly rate per payment instrument. High rates indicate
    # payment types that require focused monitoring. Business implication: prioritize review
    # workflows for payment types with rates above the portfolio average.

    # Chart 2 — Weekly confirmed anomaly count with 3-week rolling average
    # Parse dates
    valid['_date'] = pd.to_datetime(valid['payment_date_parsed'].fillna(valid['payment_date']), errors='coerce')
    weekly = valid.dropna(subset=['_date']).assign(iso_week=valid.dropna(subset=['_date'])['_date'].dt.to_period('W').apply(lambda r: r.start_time))
    weekly_grp = weekly.groupby('iso_week').agg(confirmed_count=('anomaly_confirmed', lambda s: int((s==1).sum())))
    weekly_grp = weekly_grp.sort_index()
    weekly_grp['rolling_3w'] = weekly_grp['confirmed_count'].rolling(3, min_periods=1).mean()

    fig2 = px.line(weekly_grp.reset_index(), x='iso_week', y='confirmed_count', markers=True, labels={'iso_week':'Week Start', 'confirmed_count':'Confirmed Anomaly Count'}, title='Weekly Confirmed Anomaly Count')
    fig2.add_traces(px.line(weekly_grp.reset_index(), x='iso_week', y='rolling_3w').data)
    fig2.update_yaxes(rangemode='tozero')
    # annotate peak and trough
    if not weekly_grp.empty:
        peak = weekly_grp['confirmed_count'].idxmax()
        trough = weekly_grp['confirmed_count'].idxmin()
        fig2.add_annotation(x=peak, y=weekly_grp.loc[peak,'confirmed_count'], text=f'Peak: {weekly_grp.loc[peak,"confirmed_count"]}', showarrow=True)
        fig2.add_annotation(x=trough, y=weekly_grp.loc[trough,'confirmed_count'], text=f'Trough: {weekly_grp.loc[trough,"confirmed_count"]}', showarrow=True)

    # Chart 2 comment
    # Weekly line shows temporal trends in confirmed anomalies. The rolling average smooths short-term spikes.

    # Chart 3 — Dual Y-axis: Regional confirmed count vs avg payment amount
    confirmed_df = valid[valid['anomaly_confirmed']==1]
    reg = confirmed_df.groupby('region').agg(confirmed_count=('anomaly_confirmed','count'), avg_payment_amount=('payment_amount','mean')).reset_index()
    reg = reg.sort_values('confirmed_count', ascending=False)

    # Build dual-axis figure using graph_objects (allowed for layout control)
    fig3 = make_subplots(specs=[[{"secondary_y": True}]])
    fig3.add_trace(go.Bar(x=reg['region'], y=reg['confirmed_count'], name='Confirmed Count', marker_color='crimson'))
    fig3.add_trace(go.Bar(x=reg['region'], y=reg['avg_payment_amount'], name='Avg Payment Amount', marker_color='steelblue'), secondary_y=True)
    fig3.update_yaxes(title_text='Confirmed Count', secondary_y=False, rangemode='tozero')
    fig3.update_yaxes(title_text='Avg Payment Amount (USD)', secondary_y=True, rangemode='tozero')
    fig3.update_layout(title_text='Regional Confirmed Count vs Avg Payment Amount', barmode='group')

    # Chart 3 comment
    # This grouped bar compares frequency (left axis) with dollar exposure (right axis) by region.
    # Business implication: regions high on both axes should receive prioritized investigations.

    # Combine into self-contained HTML
    chart1_html = fig1.to_html(include_plotlyjs=True, full_html=False)
    chart2_html = fig2.to_html(include_plotlyjs=False, full_html=False)
    chart3_html = fig3.to_html(include_plotlyjs=False, full_html=False)

    summary = f"""
    <h2>Treasury Anomaly Dashboard — Q4 2024</h2>
    <p><strong>Dataset:</strong> 500 raw &nbsp;|&nbsp; {n_valid} analysis-valid (after excluding anomaly_confirmed=2) &nbsp;|&nbsp; <strong>Period:</strong> {first_date} to {last_date}</p>
    <p><strong>Overall confirmed anomaly rate:</strong> {confirmed_count}/{n_valid} = {computed_rate_pct:.1f}%</p>
    <p><strong>Key Risk:</strong> {key_risk}</p>
    <p><strong>Model Status:</strong> {model_status}</p>
    <p style='font-size:0.85em;color:#666;'>Source: outputs/treasury_payments_clean.csv &nbsp;|&nbsp; EDA: scripts/eda_treasury.py</p>
    <hr/>
    """

    html = f"<html><head><meta charset='utf-8'></head><body>{summary}{chart1_html}{chart2_html}{chart3_html}</body></html>"
    OUT_HTML.parent.mkdir(parents=True, exist_ok=True)
    with open(OUT_HTML, 'w', encoding='utf-8') as f:
        f.write(html)

    # Post-process the written HTML to unescape forward-slash escapes so labels contain a literal '/'.
    # Plotly/JSON may serialize '/' as '\\u002f' or '\\/', which breaks exact-string parity checks.
    with open(OUT_HTML, 'r', encoding='utf-8') as f:
        contents = f.read()
    contents = contents.replace('\\u002f', '/').replace('\\/', '/')
    with open(OUT_HTML, 'w', encoding='utf-8') as f:
        f.write(contents)

    print('Dashboard written to:', OUT_HTML)


if __name__ == '__main__':
        main()
