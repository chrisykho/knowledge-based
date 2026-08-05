# Hermes Scripts Overview

Scripts in `/root/.hermes/scripts/`:

| Script | Purpose | Cron |
|--------|---------|------|
| `iamsmart_news.py` | 智方便 news digest | Daily 04:00 UTC |
| `daily_papers_digest.py` | HuggingFace AI papers | Daily 04:00 UTC |
| `daily_stock_report.py` | Stock report (13 stocks + Fed rate) | Mon-Fri 04:05 UTC |
| `weekly_govapps.py` | GovHK mobile apps report | Saturday 04:00 UTC |
| `backup_history.sh` | Backup .hermes_history to S3 | Daily 04:00 UTC |
| `knowledge-server.sh` | Start/stop knowledge base web server | Manual |

Logs: `/temp/logs/`