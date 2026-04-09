#!/bin/bash

echo "╔══════════════════════════════════════════════════════════╗"
echo "║         Flutter Code Quality Analysis Report            ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

# Run analysis
echo "🔍 Running Flutter analyzer..."
flutter analyze 2>&1 > /tmp/flutter_analysis.log

# Summary
echo "📊 SUMMARY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
grep "issues found" /tmp/flutter_analysis.log
echo ""

# Top issues
echo "🎯 TOP ISSUES BY TYPE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
grep -E "warning|error" /tmp/flutter_analysis.log | awk -F' • ' '{print $2}' | sort | uniq -c | sort -rn | head -10
echo ""

# Severity breakdown
echo "⚠️  SEVERITY BREAKDOWN"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Errors:   $(grep -c "^error" /tmp/flutter_analysis.log)"
echo "Warnings: $(grep -c "^warning" /tmp/flutter_analysis.log)"
echo "Info:     $(grep -c "^   info" /tmp/flutter_analysis.log)"
echo ""

# Auto-fixable
echo "🔧 AUTO-FIXABLE ISSUES"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
dart fix --dry-run 2>&1 | grep "changes" || echo "No auto-fixes available"
echo ""

# Export options
echo "📁 EXPORT OPTIONS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Full log: /tmp/flutter_analysis.log"
echo ""
echo "Generate detailed reports? (y/n)"
read answer

if [ "$answer" = "y" ]; then
    # Warnings only
    grep "warning" /tmp/flutter_analysis.log > warnings.txt
    echo "✓ Warnings saved to: warnings.txt"
    
    # Info only
    grep "info" /tmp/flutter_analysis.log > info.txt
    echo "✓ Info saved to: info.txt"
    
    # Summary
    grep -E "warning|error" /tmp/flutter_analysis.log | awk -F' • ' '{print $2}' | sort | uniq -c | sort -rn > summary.txt
    echo "✓ Summary saved to: summary.txt"
    
    echo ""
    echo "Reports generated! ✨"
fi

echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║                    Analysis Complete                     ║"
echo "╚══════════════════════════════════════════════════════════╝"
