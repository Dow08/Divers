#!/usr/bin/env python3
"""
Website Test Report Generator
Generates an ODT report from test results
"""

from datetime import datetime
from odf.opendocument import OpenDocumentText
from odf.text import P, H, Span
from odf.table import Table, TableRow, TableCell
from odf.style import Style, TextProperties, TableColumnProperties, TableRowProperties, ParagraphProperties
from odf.namespaces import STYLENS, TEXTNS, TABLENS
import sys

class WebsiteTestReport:
    def __init__(self, website_url, output_file="website_test_report.odt"):
        self.url = website_url
        self.output_file = output_file
        self.doc = OpenDocumentText()
        self.setup_styles()

    def setup_styles(self):
        """Setup ODT styles for the document"""
        # Title style
        title_style = Style(name="Title", family="paragraph")
        title_style.addAttribute("margin", "10pt")
        title_props = ParagraphProperties()
        title_props.addAttribute("textalign", "center")
        text_props = TextProperties()
        text_props.addAttribute("fontsize", "28pt")
        text_props.addAttribute("fontweight", "bold")
        title_style.addElement(text_props)
        title_style.addElement(title_props)
        self.doc.styles.addElement(title_style)

        # Heading style
        heading_style = Style(name="Heading", family="paragraph")
        heading_props = ParagraphProperties()
        heading_props.addAttribute("margin-top", "12pt")
        heading_props.addAttribute("margin-bottom", "6pt")
        text_props = TextProperties()
        text_props.addAttribute("fontsize", "16pt")
        text_props.addAttribute("fontweight", "bold")
        heading_style.addElement(text_props)
        heading_style.addElement(heading_props)
        self.doc.styles.addElement(heading_style)

    def add_title(self, title):
        """Add title to document"""
        p = P()
        p.addAttribute("stylename", "Title")
        p.addText(title)
        self.doc.text.addElement(p)

    def add_heading(self, text, level=1):
        """Add heading"""
        h = H(outlinelevel=level)
        h.addText(text)
        self.doc.text.addElement(h)

    def add_paragraph(self, text):
        """Add paragraph"""
        p = P()
        p.addText(text)
        self.doc.text.addElement(p)

    def add_table(self, headers, rows):
        """Add table to document"""
        table = Table(name="DataTable")

        # Add header row
        tr = TableRow()
        for header in headers:
            tc = TableCell()
            p = P()
            p.addText(header)
            tc.addElement(p)
            tr.addElement(tc)
        table.addElement(tr)

        # Add data rows
        for row in rows:
            tr = TableRow()
            for cell_data in row:
                tc = TableCell()
                p = P()
                p.addText(str(cell_data))
                tc.addElement(p)
                tr.addElement(tc)
            table.addElement(tr)

        self.doc.text.addElement(table)

    def save(self):
        """Save document"""
        self.doc.save(self.output_file)
        return self.output_file


def create_template_report(url):
    """Create a template report with test structure"""
    report = WebsiteTestReport(url)

    # Title
    report.add_title(f"Website Test Report\n{url}")
    report.add_paragraph(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")

    # Executive Summary
    report.add_heading("Executive Summary", 1)
    report.add_paragraph("Overall Score: [TO BE DETERMINED]")
    report.add_paragraph("Key Findings:\n• [Finding 1]\n• [Finding 2]\n• [Finding 3]")

    # Test sections
    sections = [
        ("Functionality Testing", ["Status", "Finding", "Recommendation"]),
        ("Security Analysis", ["Status", "Finding", "Recommendation"]),
        ("Performance Analysis", ["Metric", "Value", "Assessment"]),
        ("Accessibility (WCAG 2.1)", ["Status", "Issue", "Fix"]),
        ("Mobile Responsiveness", ["Viewport", "Status", "Issue"]),
        ("Cross-Browser Compatibility", ["Browser", "Status", "Issue"]),
        ("SEO Basics", ["Element", "Status", "Details"]),
    ]

    for section_name, headers in sections:
        report.add_heading(section_name, 2)
        report.add_table(headers, [
            ["[TO BE TESTED]", "[DETAILS]", "[ACTION]"]
        ])
        report.add_paragraph("")

    # Recommendations
    report.add_heading("Priority Recommendations", 1)
    report.add_heading("Critical Issues", 2)
    report.add_paragraph("[Document critical issues to fix immediately]")

    report.add_heading("High Priority", 2)
    report.add_paragraph("[Document high priority improvements]")

    report.add_heading("Medium Priority", 2)
    report.add_paragraph("[Document medium priority enhancements]")

    # Methodology
    report.add_heading("Testing Methodology", 1)
    report.add_paragraph(f"Website Tested: {url}")
    report.add_paragraph(f"Test Date: {datetime.now().strftime('%Y-%m-%d')}")
    report.add_paragraph("Browser: Chromium-based browser")
    report.add_paragraph("Viewport Sizes Tested: 375px, 768px, 1024px, 1920px")
    report.add_paragraph("WCAG Compliance Level: AA")

    return report


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python generate_report.py <url> [output_file]")
        sys.exit(1)

    url = sys.argv[1]
    output = sys.argv[2] if len(sys.argv) > 2 else "website_test_report.odt"

    report = create_template_report(url)
    saved_file = report.save()
    print(f"Report generated: {saved_file}")
