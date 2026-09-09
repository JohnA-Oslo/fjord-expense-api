"""MkDocs build hooks for Fjord Expense API documentation."""

from datetime import datetime

START_YEAR = 2025


def on_config(config, **kwargs):
    """Set the footer copyright string with a dynamic end year.

    Produces "Copyright &copy; 2025 Fjord Enterprises" while the current
    year is the start year, and "Copyright &copy; 2025-<year> Fjord
    Enterprises" once the build happens in a later year.
    """
    current_year = datetime.now().year

    if current_year > START_YEAR:
        years = f"{START_YEAR}-{current_year}"
    else:
        years = str(START_YEAR)

    config["copyright"] = f"Copyright &copy; {years} Fjord Enterprises"

    return config
