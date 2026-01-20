@echo off
echo ========================================
echo Fjord Expense API - Documentation Check
echo ========================================
echo.

echo [1/3] Running Vale style check...
vale docs/
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo Vale found issues. Review above.
    echo.
)

echo [2/3] Running Claude Code review...
claude "Review all markdown files in docs/ and check for: 1) Parallel structure in lists, 2) Error codes are lowercase, 3) Amounts are strings not numbers, 4) All error responses include request_id, 5) Broken internal links, 6) Clarity issues"
echo.

echo [3/3] Checking for common issues...
claude "Scan for placeholder text like 'yourusername' or 'TODO' or 'FIXME'"
echo.

echo ========================================
echo Pre-commit checks complete
echo Review feedback above before committing
echo ========================================
pause