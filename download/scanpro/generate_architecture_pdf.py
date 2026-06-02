#!/usr/bin/env python3
"""
ScanPro Architecture Document PDF Generator
Comprehensive architecture document for the ScanPro Flutter document scanning application.
Uses ReportLab for PDF generation with TocDocTemplate + multiBuild for auto-generated TOC.
Cover page rendered via html2poster.js (HTML/Playwright).
"""

import os
import sys
import hashlib
import subprocess
from pathlib import Path

from reportlab.lib.pagesizes import A4
from reportlab.lib.units import inch, cm
from reportlab.lib import colors
from reportlab.lib.enums import TA_LEFT, TA_CENTER, TA_JUSTIFY
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.platypus import (
    Paragraph, Spacer, Table, TableStyle, PageBreak, KeepTogether,
    CondPageBreak, Flowable
)
from reportlab.platypus.tableofcontents import TableOfContents
from reportlab.platypus import SimpleDocTemplate
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.pdfbase.pdfmetrics import registerFontFamily

# ═══════════════════════════════════════════════════════════════
# PALETTE COLORS (as specified)
# ═══════════════════════════════════════════════════════════════
ACCENT       = colors.HexColor('#4d2dab')
TEXT_PRIMARY  = colors.HexColor('#22211f')
TEXT_MUTED    = colors.HexColor('#827e76')
BG_SURFACE   = colors.HexColor('#e0ded9')
BG_PAGE      = colors.HexColor('#efeeec')

TABLE_HEADER_COLOR = ACCENT
TABLE_HEADER_TEXT  = colors.white
TABLE_ROW_EVEN     = colors.white
TABLE_ROW_ODD      = BG_SURFACE

# ═══════════════════════════════════════════════════════════════
# FONT REGISTRATION
# ═══════════════════════════════════════════════════════════════
pdfmetrics.registerFont(TTFont('SimHei', '/usr/share/fonts/truetype/chinese/SarasaMonoSC-Regular.ttf'))
pdfmetrics.registerFont(TTFont('Times New Roman', '/usr/share/fonts/truetype/liberation/LiberationSerif-Regular.ttf'))
pdfmetrics.registerFont(TTFont('Times New Roman Bold', '/usr/share/fonts/truetype/liberation/LiberationSerif-Bold.ttf'))
pdfmetrics.registerFont(TTFont('DejaVuSans', '/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf'))
pdfmetrics.registerFont(TTFont('DejaVuSans Bold', '/usr/share/fonts/truetype/dejavu/DejaVuSansMono-Bold.ttf'))

registerFontFamily('SimHei', normal='SimHei', bold='SimHei')
registerFontFamily('Times New Roman', normal='Times New Roman', bold='Times New Roman Bold')
registerFontFamily('DejaVuSans', normal='DejaVuSans', bold='DejaVuSans Bold')

# Install font fallback for mixed CJK/Latin text
PDF_SKILL_DIR = os.path.expanduser('/home/z/my-project/skills/pdf')
sys.path.insert(0, os.path.join(PDF_SKILL_DIR, 'scripts'))
try:
    from pdf import install_font_fallback
    install_font_fallback()
except Exception:
    pass

# ═══════════════════════════════════════════════════════════════
# PAGE SETUP
# ═══════════════════════════════════════════════════════════════
PAGE_W, PAGE_H = A4
LEFT_MARGIN = 1.0 * inch
RIGHT_MARGIN = 1.0 * inch
TOP_MARGIN = 0.8 * inch
BOTTOM_MARGIN = 0.8 * inch
AVAILABLE_WIDTH = PAGE_W - LEFT_MARGIN - RIGHT_MARGIN

OUTPUT_DIR = '/home/z/my-project/download/scanpro'
BODY_PDF = os.path.join(OUTPUT_DIR, '_body.pdf')
COVER_HTML = os.path.join(OUTPUT_DIR, '_cover.html')
COVER_PDF = os.path.join(OUTPUT_DIR, '_cover.pdf')
FINAL_PDF = os.path.join(OUTPUT_DIR, 'ScanPro_Architecture_Document.pdf')

# ═══════════════════════════════════════════════════════════════
# STYLES
# ═══════════════════════════════════════════════════════════════
styles = getSampleStyleSheet()

title_style = ParagraphStyle(
    name='DocTitle', fontName='Times New Roman', fontSize=24, leading=30,
    textColor=ACCENT, alignment=TA_LEFT, spaceBefore=0, spaceAfter=12
)

h1_style = ParagraphStyle(
    name='H1Style', fontName='Times New Roman', fontSize=18, leading=24,
    textColor=ACCENT, alignment=TA_LEFT, spaceBefore=18, spaceAfter=10
)

h2_style = ParagraphStyle(
    name='H2Style', fontName='Times New Roman', fontSize=14, leading=20,
    textColor=TEXT_PRIMARY, alignment=TA_LEFT, spaceBefore=12, spaceAfter=6
)

h3_style = ParagraphStyle(
    name='H3Style', fontName='Times New Roman', fontSize=12, leading=17,
    textColor=TEXT_PRIMARY, alignment=TA_LEFT, spaceBefore=8, spaceAfter=4
)

body_style = ParagraphStyle(
    name='BodyStyle', fontName='Times New Roman', fontSize=10.5, leading=17,
    textColor=TEXT_PRIMARY, alignment=TA_JUSTIFY, spaceBefore=0, spaceAfter=6,
    firstLineIndent=0
)

code_style = ParagraphStyle(
    name='CodeStyle', fontName='DejaVuSans', fontSize=8.5, leading=12,
    textColor=TEXT_PRIMARY, alignment=TA_LEFT, spaceBefore=4, spaceAfter=4,
    leftIndent=12, backColor=BG_PAGE
)

bullet_style = ParagraphStyle(
    name='BulletStyle', fontName='Times New Roman', fontSize=10.5, leading=17,
    textColor=TEXT_PRIMARY, alignment=TA_LEFT, spaceBefore=2, spaceAfter=2,
    leftIndent=24, bulletIndent=12
)

toc_h1_style = ParagraphStyle(
    name='TOCH1', fontName='Times New Roman', fontSize=13, leading=22,
    leftIndent=20, textColor=TEXT_PRIMARY
)

toc_h2_style = ParagraphStyle(
    name='TOCH2', fontName='Times New Roman', fontSize=11, leading=18,
    leftIndent=40, textColor=TEXT_MUTED
)

header_cell_style = ParagraphStyle(
    name='HeaderCell', fontName='Times New Roman', fontSize=10,
    textColor=TABLE_HEADER_TEXT, alignment=TA_CENTER, leading=14
)

cell_style = ParagraphStyle(
    name='CellStyle', fontName='Times New Roman', fontSize=9.5,
    textColor=TEXT_PRIMARY, alignment=TA_LEFT, leading=13
)

cell_center_style = ParagraphStyle(
    name='CellCenter', fontName='Times New Roman', fontSize=9.5,
    textColor=TEXT_PRIMARY, alignment=TA_CENTER, leading=13
)

# ═══════════════════════════════════════════════════════════════
# TOC DOCUMENT TEMPLATE
# ═══════════════════════════════════════════════════════════════
class TocDocTemplate(SimpleDocTemplate):
    def afterFlowable(self, flowable):
        if hasattr(flowable, 'bookmark_name'):
            level = getattr(flowable, 'bookmark_level', 0)
            text = getattr(flowable, 'bookmark_text', '')
            key = getattr(flowable, 'bookmark_key', '')
            self.notify('TOCEntry', (level, text, self.page, key))


# ═══════════════════════════════════════════════════════════════
# HELPER FUNCTIONS
# ═══════════════════════════════════════════════════════════════
def add_heading(text, style, level=0):
    key = 'h_%s' % hashlib.md5(text.encode()).hexdigest()[:8]
    p = Paragraph('<a name="%s"/>%s' % (key, text), style)
    p.bookmark_name = text
    p.bookmark_level = level
    p.bookmark_text = text
    p.bookmark_key = key
    return p

H1_ORPHAN_THRESHOLD = (PAGE_H - TOP_MARGIN - BOTTOM_MARGIN) * 0.15

def add_major_section(text):
    return [
        CondPageBreak(H1_ORPHAN_THRESHOLD),
        add_heading(text, h1_style, level=0),
    ]

def make_table(data, col_ratios=None, col_widths_override=None):
    """Create a styled table with Paragraph() wrapping in all cells."""
    if col_widths_override:
        cw = col_widths_override
    elif col_ratios:
        cw = [r * AVAILABLE_WIDTH for r in col_ratios]
    else:
        cw = None
    t = Table(data, colWidths=cw, hAlign='CENTER')
    style_commands = [
        ('BACKGROUND', (0, 0), (-1, 0), TABLE_HEADER_COLOR),
        ('TEXTCOLOR', (0, 0), (-1, 0), TABLE_HEADER_TEXT),
        ('GRID', (0, 0), (-1, -1), 0.5, TEXT_MUTED),
        ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
        ('LEFTPADDING', (0, 0), (-1, -1), 8),
        ('RIGHTPADDING', (0, 0), (-1, -1), 8),
        ('TOPPADDING', (0, 0), (-1, -1), 6),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
    ]
    for i in range(1, len(data)):
        bg = TABLE_ROW_EVEN if i % 2 == 1 else TABLE_ROW_ODD
        style_commands.append(('BACKGROUND', (0, i), (-1, i), bg))
    t.setStyle(TableStyle(style_commands))
    return t

def P(text, style=None):
    return Paragraph(text, style or body_style)

def HP(text):
    return Paragraph('<b>%s</b>' % text, header_cell_style)

def CP(text, style=None):
    return Paragraph(text, style or cell_style)

def CC(text):
    return Paragraph(text, cell_center_style)

# ═══════════════════════════════════════════════════════════════
# COVER PAGE HTML GENERATION
# ═══════════════════════════════════════════════════════════════
def generate_cover_html():
    """Generate cover HTML using Template 01: HUD Data Terminal style."""
    html_content = '''<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>ScanPro Architecture Document</title>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;700;900&display=swap" rel="stylesheet">
<style>
  @page { margin: 0; size: 794px 1123px; }
  * { box-sizing: border-box; margin: 0; padding: 0; }
  html, body {
    margin: 0; padding: 0;
    width: 794px; height: 1123px;
    background: #ffffff;
    font-family: 'Inter', sans-serif;
    overflow: hidden;
  }
  .cover-page {
    position: relative;
    width: 794px; height: 1123px;
    background: #ffffff;
  }
  /* Layer 1: Background grid */
  .bg-grid {
    position: absolute; inset: 0; z-index: 1; overflow: hidden;
  }
  .bg-grid .h-line, .bg-grid .v-line {
    position: absolute; background: #4d2dab; opacity: 0.03;
  }
  .bg-grid .h-line { left: 0; right: 0; height: 0.5pt; }
  .bg-grid .v-line { top: 0; bottom: 0; width: 0.5pt; }
  /* Layer 2: Structure - thick left anchor line */
  .anchor-line {
    position: absolute;
    left: 95px; top: 112px; bottom: 112px;
    width: 6pt; background: #4d2dab;
    z-index: 2;
  }
  .meta-line {
    position: absolute;
    left: 125px; top: 775px;
    width: 280px; height: 1pt;
    background: #4d2dab; opacity: 0.4;
    z-index: 2;
  }
  /* Layer 3: Content */
  .kicker {
    position: absolute;
    left: 125px; top: 170px;
    font-size: 16pt; font-weight: 400;
    letter-spacing: 3pt; color: #4d2dab; opacity: 0.6;
    text-transform: uppercase; z-index: 3;
  }
  .hero-title {
    position: absolute;
    left: 125px; top: 280px;
    font-size: 56pt; font-weight: 900;
    color: #22211f; line-height: 1.15;
    z-index: 3;
  }
  .summary {
    position: absolute;
    left: 125px; top: 530px;
    width: 460px;
    font-size: 16pt; font-weight: 400;
    color: #22211f; opacity: 0.85;
    line-height: 1.6; z-index: 3;
  }
  .meta {
    position: absolute;
    left: 125px; top: 800px;
    font-size: 18pt; font-weight: 400;
    color: #827e76; line-height: 2.0;
    z-index: 3;
  }
  .footer {
    position: absolute;
    left: 125px; bottom: 80px;
    font-size: 13pt; font-weight: 400;
    color: #827e76; opacity: 0.6;
    letter-spacing: 1pt; z-index: 3;
  }
</style>
</head>
<body>
<div class="cover-page">
  <div class="bg-grid">
    <script>
      /* Generate grid lines */
      for (let y = 0; y <= 1123; y += 50) {
        const l = document.createElement('div');
        l.className = 'h-line'; l.style.top = y + 'px';
        document.querySelector('.bg-grid').appendChild(l);
      }
      for (let x = 0; x <= 794; x += 50) {
        const l = document.createElement('div');
        l.className = 'v-line'; l.style.left = x + 'px';
        document.querySelector('.bg-grid').appendChild(l);
      }
    </script>
  </div>
  <div class="anchor-line"></div>
  <div class="meta-line"></div>
  <div class="kicker">FLUTTER APPLICATION</div>
  <div class="hero-title">ScanPro<br/>Architecture</div>
  <div class="summary">Comprehensive technical architecture document for the ScanPro document scanning application, covering system design, data models, engine implementations, and deployment strategy.</div>
  <div class="meta">Version 1.0<br/>March 2026<br/>Z.ai Engineering</div>
  <div class="footer">CONFIDENTIAL</div>
</div>
</body>
</html>'''
    with open(COVER_HTML, 'w', encoding='utf-8') as f:
        f.write(html_content)
    print(f"Cover HTML generated: {COVER_HTML}")

# ═══════════════════════════════════════════════════════════════
# BUILD BODY PDF CONTENT
# ═══════════════════════════════════════════════════════════════
def build_story():
    story = []

    # ── Table of Contents ──
    story.append(Paragraph('<b>Table of Contents</b>', title_style))
    story.append(Spacer(1, 12))
    toc = TableOfContents()
    toc.levelStyles = [toc_h1_style, toc_h2_style]
    story.append(toc)
    story.append(PageBreak())

    # ═══════════════════════════════════════════════════════════
    # SECTION 1: Project Overview
    # ═══════════════════════════════════════════════════════════
    story.extend(add_major_section('1. Project Overview'))
    story.append(P(
        '<b>ScanPro</b> is a comprehensive mobile document scanning application built with Flutter, '
        'designed to transform any smartphone into a powerful portable document scanner. The application '
        'falls under the Productivity category on both Google Play Store and Apple App Store, targeting '
        'Android as the primary platform with future iOS expansion planned. ScanPro leverages the full '
        'power of modern mobile hardware, combining advanced camera APIs, on-device machine learning, '
        'and cloud-based AI services to deliver an unparalleled document management experience.'
    ))
    story.append(P(
        'The core goal of ScanPro is to simplify the entire document lifecycle: from capture and '
        'enhancement, through organization and search, to sharing and collaboration. Unlike basic scanner '
        'apps that merely photograph documents, ScanPro provides intelligent edge detection, perspective '
        'correction, multi-mode image enhancement, and full-text OCR that makes every scanned document '
        'instantly searchable. The application integrates with Google Gemini AI for smart features like '
        'automatic document summarization, intelligent renaming, auto-categorization, tag generation, '
        'and cross-language translation.'
    ))
    story.append(P(
        'Target users include business professionals who need to digitize contracts and receipts on the go, '
        'students scanning lecture notes and textbook pages, legal professionals managing case documents, '
        'and healthcare workers processing patient forms. The value proposition is clear: ScanPro replaces '
        'bulky desktop scanners with a pocket-sized solution that produces professional-quality results in '
        'seconds. With Firebase-powered cloud sync, end-to-end encryption, and biometric security, users '
        'can trust that their sensitive documents are both accessible and protected across all their devices.'
    ))

    # ═══════════════════════════════════════════════════════════
    # SECTION 2: Clean Architecture Design
    # ═══════════════════════════════════════════════════════════
    story.extend(add_major_section('2. Clean Architecture Design'))
    story.append(P(
        'ScanPro follows the Clean Architecture pattern as popularized by Robert C. Martin, organized '
        'into four distinct layers with strict dependency rules. This architectural choice ensures that '
        'the business logic of the application remains independent of framework concerns, database '
        'implementations, or UI details, making the codebase highly testable, maintainable, and adaptable '
        'to changing requirements. Each layer has a single responsibility and communicates with adjacent '
        'layers through well-defined interfaces.'
    ))

    story.append(add_heading('2.1 Presentation Layer', h2_style, level=1))
    story.append(P(
        'The Presentation layer contains all UI-related code including pages (screens), widgets (reusable '
        'UI components), and providers (Riverpod state management). This layer is responsible for rendering '
        'the user interface and handling user interactions. It depends exclusively on the Domain layer through '
        'use case interfaces, never directly accessing data sources or repositories. Riverpod providers serve '
        'as the bridge between UI and domain logic, with StateNotifiers encapsulating state transitions. The '
        'presentation layer follows the MVVM (Model-View-ViewModel) pattern where each page has a corresponding '
        'provider that manages its state and delegates business operations to domain use cases.'
    ))

    story.append(add_heading('2.2 Domain Layer', h2_style, level=1))
    story.append(P(
        'The Domain layer is the heart of the application and contains pure business logic with zero '
        'external dependencies. It defines entities (business objects), use cases (application-specific '
        'business rules), and repository interfaces (contracts that the Data layer must implement). Every '
        'use case represents a single application action, following the Single Responsibility Principle. '
        'For example, the CaptureDocument use case encapsulates the business logic for scanning a document, '
        'while the DetectEdges use case handles the edge detection workflow. Repository interfaces are '
        'defined here but implemented in the Data layer, enabling dependency inversion. This layer is '
        'written in pure Dart with no Flutter or third-party dependencies, ensuring maximum portability.'
    ))

    story.append(add_heading('2.3 Data Layer', h2_style, level=1))
    story.append(P(
        'The Data layer implements the repository interfaces defined in the Domain layer and manages all '
        'data operations including local storage (Hive), remote storage (Firebase), and external service '
        'integrations (Google ML Kit, Gemini API, OpenCV). It consists of models (data transfer objects), '
        'repository implementations, data sources (local and remote), and service wrappers. The Data layer '
        'follows the Repository Pattern, where each repository implementation coordinates between local and '
        'remote data sources, implementing caching strategies, offline-first patterns, and data synchronization '
        'logic. Mappers convert between external data formats and domain entities, maintaining clean boundaries.'
    ))

    story.append(add_heading('2.4 Core Layer', h2_style, level=1))
    story.append(P(
        'The Core layer provides cross-cutting concerns shared across all other layers: constants, error '
        'handling (failures and exceptions), utility extensions, network connectivity checking, theme '
        'configuration, and reusable widgets. This layer has no business logic itself but provides the '
        'infrastructure that other layers depend on. It follows the DRY (Don\'t Repeat Yourself) principle, '
        'consolidating common functionality into a single source of truth. The Core layer also defines the '
        'Failure hierarchy used by the Domain layer for error propagation, ensuring consistent error handling '
        'throughout the application.'
    ))

    # Architecture layers table
    arch_data = [
        [HP('Layer'), HP('Responsibility'), HP('Key Components'), HP('Dependency Rule')],
        [CP('Presentation'), CP('UI rendering, user interaction, state management'),
         CP('Pages, Widgets, Riverpod Providers'), CP('Depends on Domain only')],
        [CP('Domain'), CP('Business logic, use cases, entity definitions'),
         CP('Entities, Use Cases, Repository Interfaces'), CP('No external dependencies')],
        [CP('Data'), CP('Data access, repository implementations, external services'),
         CP('Models, Repositories, Data Sources, Services'), CP('Depends on Domain only')],
        [CP('Core'), CP('Cross-cutting concerns, shared infrastructure'),
         CP('Constants, Errors, Extensions, Theme, Utils'), CP('No business logic')],
    ]
    story.append(Spacer(1, 18))
    story.append(make_table(arch_data, col_ratios=[0.15, 0.30, 0.30, 0.25]))
    story.append(Spacer(1, 18))

    # ═══════════════════════════════════════════════════════════
    # SECTION 3: Complete Folder Structure
    # ═══════════════════════════════════════════════════════════
    story.extend(add_major_section('3. Complete Folder Structure'))
    story.append(P(
        'ScanPro adopts a feature-based modular folder structure that scales gracefully as the application '
        'grows. Each feature module encapsulates its own presentation, domain, and data layers, following '
        'the same Clean Architecture pattern at the module level. This approach provides strong separation '
        'of concerns, enables parallel development across teams, and makes it straightforward to extract '
        'features into separate packages if needed. The root directory separates the Flutter application '
        'code (lib/), platform-specific configurations (android/), static assets (assets/), and tests (test/).'
    ))
    story.append(P(
        'Within the lib/ directory, the core/ folder houses shared infrastructure used across all features. '
        'The features/ directory contains 14 feature modules: home, scanner, documents, ocr, pdf_tools, '
        'search, cloud_sync, security, ai_features, signature, annotations, qr_scanner, profile, and settings. '
        'Each feature module internally mirrors the three-layer architecture with presentation/, domain/, and '
        'data/ subdirectories. The di/ (dependency injection) directory at the root level manages module '
        'registration and provider assembly, with dedicated injection modules for each major engine: scanner, '
        'OCR, PDF, sync, security, and AI.'
    ))

    folder_tree_text = """scanpro/
lib/
  main.dart
  app.dart
  core/
    constants/ (app_constants, db_constants, firebase_constants, api_constants)
    errors/ (failures, exceptions)
    extensions/ (context_extensions, string_extensions, date_extensions)
    network/ (network_info, api_client)
    theme/ (app_theme, color_schemes, text_styles, dimensions)
    utils/ (file_utils, image_utils, date_utils, validators)
    widgets/ (loading_widget, error_widget, empty_state, custom_app_bar)
  features/
    home/ (presentation, domain, data)
    scanner/ (presentation/pages, domain/usecases, data/services)
    documents/ (presentation/pages, domain, data)
    ocr/ (presentation, domain, data)
    pdf_tools/ (presentation/pages, domain, data)
    search/ (presentation, domain, data)
    cloud_sync/ (presentation, domain, data)
    security/ (presentation/pages, domain, data)
    ai_features/ (presentation, domain, data)
    signature/ (presentation, domain, data)
    annotations/ (presentation, domain, data)
    qr_scanner/ (presentation, domain, data)
    profile/ (presentation, domain, data)
    settings/ (presentation, domain, data)
  di/
    injection.dart
    modules/ (scanner, ocr, pdf, sync, security, ai modules)
android/ (app/build.gradle, AndroidManifest.xml, kotlin/)
assets/ (fonts/, images/, icons/)
test/ (unit/, widget/, integration/)
pubspec.yaml"""

    # Present folder structure in a table
    folder_lines = folder_tree_text.strip().split('\n')
    folder_data = [[HP('Path'), HP('Description')]]
    descriptions = {
        'main.dart': 'Application entry point and initialization',
        'app.dart': 'Root widget with router and provider scope',
        'core/': 'Shared infrastructure (constants, errors, extensions, theme, utils, widgets)',
        'features/': '14 feature modules following Clean Architecture',
        'di/': 'Dependency injection setup and module registration',
        'android/': 'Android platform configuration',
        'assets/': 'Static resources (fonts, images, icons)',
        'test/': 'Unit, widget, and integration test suites',
        'pubspec.yaml': 'Project manifest with dependencies',
    }
    for line in folder_lines:
        stripped = line.strip()
        if stripped:
            desc = descriptions.get(stripped, '')
            if not desc:
                for key, val in descriptions.items():
                    if stripped.startswith(key.rstrip('/')) or key.rstrip('/') in stripped:
                        desc = val
                        break
            folder_data.append([CP(stripped), CP(desc)])
    story.append(Spacer(1, 12))
    story.append(make_table(folder_data, col_ratios=[0.45, 0.55]))
    story.append(Spacer(1, 18))

    # ═══════════════════════════════════════════════════════════
    # SECTION 4: Database Schema
    # ═══════════════════════════════════════════════════════════
    story.extend(add_major_section('4. Database Schema'))
    story.append(P(
        'ScanPro uses Hive as its primary local database, chosen for its excellent Flutter integration, '
        'fast performance with lazy loading, and native support for complex data structures. The database '
        'schema consists of 10 Hive models that cover all aspects of document management, from the core '
        'Document entity to auxiliary models for OCR results, signatures, annotations, and synchronization '
        'tracking. Each model is annotated with Hive type adapters and field annotations for seamless '
        'serialization and deserialization. The schema is designed to support offline-first operation with '
        'efficient indexing for search operations.'
    ))

    # Document table
    story.append(add_heading('4.1 Document Model', h2_style, level=1))
    doc_data = [
        [HP('Field'), HP('Type'), HP('Description')],
        [CP('id'), CC('String'), CP('Unique identifier (UUID v4)')],
        [CP('title'), CC('String'), CP('Document display name')],
        [CP('filePath'), CC('String'), CP('Original image file path')],
        [CP('thumbnailPath'), CC('String'), CP('Thumbnail image path')],
        [CP('pdfPath'), CC('String'), CP('Generated PDF file path')],
        [CP('folderId'), CC('String?'), CP('Parent folder reference')],
        [CP('tags'), CC('List<String>'), CP('Associated tag IDs')],
        [CP('isFavorite'), CC('bool'), CP('Favorite flag for quick access')],
        [CP('isArchived'), CC('bool'), CP('Archive status flag')],
        [CP('isDeleted'), CC('bool'), CP('Soft delete flag for trash')],
        [CP('createdAt'), CC('DateTime'), CP('Creation timestamp')],
        [CP('updatedAt'), CC('DateTime'), CP('Last modification timestamp')],
        [CP('fileSize'), CC('int'), CP('File size in bytes')],
        [CP('pageCount'), CC('int'), CP('Number of pages in document')],
        [CP('ocrText'), CC('String'), CP('Extracted OCR text content')],
        [CP('syncStatus'), CC('SyncStatus'), CP('Enum: synced, pending, conflict')],
    ]
    story.append(Spacer(1, 12))
    story.append(make_table(doc_data, col_ratios=[0.20, 0.18, 0.62]))
    story.append(Spacer(1, 12))

    # Folder & Tag
    story.append(add_heading('4.2 Folder Model', h2_style, level=1))
    folder_data = [
        [HP('Field'), HP('Type'), HP('Description')],
        [CP('id'), CC('String'), CP('Unique identifier')],
        [CP('name'), CC('String'), CP('Folder display name')],
        [CP('parentId'), CC('String?'), CP('Parent folder for nesting')],
        [CP('color'), CC('int'), CP('ARGB color value')],
        [CP('icon'), CC('String'), CP('Icon identifier for display')],
        [CP('createdAt'), CC('DateTime'), CP('Creation timestamp')],
    ]
    story.append(make_table(folder_data, col_ratios=[0.20, 0.18, 0.62]))
    story.append(Spacer(1, 12))

    story.append(add_heading('4.3 Tag Model', h2_style, level=1))
    tag_data = [
        [HP('Field'), HP('Type'), HP('Description')],
        [CP('id'), CC('String'), CP('Unique identifier')],
        [CP('name'), CC('String'), CP('Tag label text')],
        [CP('color'), CC('int'), CP('ARGB color value')],
        [CP('createdAt'), CC('DateTime'), CP('Creation timestamp')],
    ]
    story.append(make_table(tag_data, col_ratios=[0.20, 0.18, 0.62]))
    story.append(Spacer(1, 12))

    # OCRResult
    story.append(add_heading('4.4 OCRResult Model', h2_style, level=1))
    story.append(P(
        'The OCRResult model stores the output of text recognition operations. It links to a Document '
        'via the documentId field and contains the full extracted text, detected language, confidence score '
        'as a percentage, and a list of detected smart actions (phone numbers, URLs, email addresses). '
        'This model enables full-text search across documents and powers the smart action detection feature '
        'that highlights actionable content within scanned text.'
    ))
    ocr_data = [
        [HP('Field'), HP('Type'), HP('Description')],
        [CP('id'), CC('String'), CP('Unique identifier')],
        [CP('documentId'), CC('String'), CP('Reference to source document')],
        [CP('text'), CC('String'), CP('Full extracted text content')],
        [CP('language'), CC('String'), CP('Detected language code (e.g., en, zh)')],
        [CP('confidence'), CC('double'), CP('Recognition confidence (0.0-1.0)')],
        [CP('smartActions'), CC('List<SmartAction>'), CP('Detected actionable items')],
        [CP('createdAt'), CC('DateTime'), CP('Processing timestamp')],
    ]
    story.append(make_table(ocr_data, col_ratios=[0.20, 0.18, 0.62]))
    story.append(Spacer(1, 12))

    # Signature, Annotation, ScanSettings
    story.append(add_heading('4.5 Signature Model', h2_style, level=1))
    sig_data = [
        [HP('Field'), HP('Type'), HP('Description')],
        [CP('id'), CC('String'), CP('Unique identifier')],
        [CP('name'), CC('String'), CP('Signature display label')],
        [CP('imageData'), CC('Uint8List'), CP('PNG image bytes of signature')],
        [CP('createdAt'), CC('DateTime'), CP('Creation timestamp')],
    ]
    story.append(make_table(sig_data, col_ratios=[0.20, 0.18, 0.62]))
    story.append(Spacer(1, 12))

    story.append(add_heading('4.6 Annotation Model', h2_style, level=1))
    ann_data = [
        [HP('Field'), HP('Type'), HP('Description')],
        [CP('id'), CC('String'), CP('Unique identifier')],
        [CP('documentId'), CC('String'), CP('Reference to document')],
        [CP('pageIndex'), CC('int'), CP('Zero-based page index')],
        [CP('type'), CC('AnnotationType'), CP('Enum: highlight, note, drawing, text')],
        [CP('data'), CC('String'), CP('JSON-encoded annotation data')],
        [CP('color'), CC('int'), CP('ARGB color value')],
        [CP('position'), CC('String'), CP('JSON-encoded position/rect')],
        [CP('createdAt'), CC('DateTime'), CP('Creation timestamp')],
    ]
    story.append(make_table(ann_data, col_ratios=[0.20, 0.18, 0.62]))
    story.append(Spacer(1, 12))

    story.append(add_heading('4.7 ScanSettings Model', h2_style, level=1))
    scan_data = [
        [HP('Field'), HP('Type'), HP('Description')],
        [CP('id'), CC('String'), CP('Unique identifier (singleton)')],
        [CP('autoCapture'), CC('bool'), CP('Auto-capture when document detected')],
        [CP('enhancementMode'), CC('EnhancementMode'), CP('Enum: none, auto, vivid, grayscale')],
        [CP('colorMode'), CC('ColorMode'), CP('Enum: color, grayscale, bw')],
        [CP('quality'), CC('int'), CP('JPEG quality (70-100)')],
        [CP('flashMode'), CC('FlashMode'), CP('Enum: auto, on, off')],
    ]
    story.append(make_table(scan_data, col_ratios=[0.22, 0.20, 0.58]))
    story.append(Spacer(1, 12))

    # UserProfile, SyncRecord, SearchIndex
    story.append(add_heading('4.8 UserProfile Model', h2_style, level=1))
    profile_data = [
        [HP('Field'), HP('Type'), HP('Description')],
        [CP('id'), CC('String'), CP('Firebase UID')],
        [CP('name'), CC('String'), CP('Display name')],
        [CP('email'), CC('String'), CP('Email address')],
        [CP('photoUrl'), CC('String?'), CP('Profile photo URL')],
        [CP('isPremium'), CC('bool'), CP('Premium subscription status')],
        [CP('syncEnabled'), CC('bool'), CP('Cloud sync preference')],
        [CP('backupEnabled'), CC('bool'), CP('Auto-backup preference')],
        [CP('lastSyncAt'), CC('DateTime?'), CP('Last successful sync time')],
    ]
    story.append(make_table(profile_data, col_ratios=[0.20, 0.18, 0.62]))
    story.append(Spacer(1, 12))

    story.append(add_heading('4.9 SyncRecord Model', h2_style, level=1))
    sync_data = [
        [HP('Field'), HP('Type'), HP('Description')],
        [CP('id'), CC('String'), CP('Unique identifier')],
        [CP('documentId'), CC('String'), CP('Reference to document')],
        [CP('operation'), CC('SyncOperation'), CP('Enum: create, update, delete')],
        [CP('timestamp'), CC('DateTime'), CP('Operation timestamp')],
        [CP('status'), CC('SyncStatus'), CP('Enum: pending, completed, conflict')],
        [CP('conflictData'), CC('String?'), CP('JSON of conflicting server data')],
    ]
    story.append(make_table(sync_data, col_ratios=[0.20, 0.18, 0.62]))
    story.append(Spacer(1, 12))

    story.append(add_heading('4.10 SearchIndex Model', h2_style, level=1))
    search_data = [
        [HP('Field'), HP('Type'), HP('Description')],
        [CP('id'), CC('String'), CP('Unique identifier')],
        [CP('documentId'), CC('String'), CP('Reference to document')],
        [CP('text'), CC('String'), CP('Indexed text fragment')],
        [CP('fieldName'), CC('String'), CP('Source field (title, ocrText, tags)')],
        [CP('timestamp'), CC('DateTime'), CP('Index creation timestamp')],
    ]
    story.append(make_table(search_data, col_ratios=[0.20, 0.18, 0.62]))
    story.append(Spacer(1, 18))

    # ═══════════════════════════════════════════════════════════
    # SECTION 5: Firebase Structure
    # ═══════════════════════════════════════════════════════════
    story.extend(add_major_section('5. Firebase Structure'))
    story.append(P(
        'ScanPro leverages the full Firebase suite for cloud infrastructure, providing authentication, '
        'real-time data storage, file storage, and cloud functions. The Firebase structure follows a '
        'user-scoped architecture where all data is partitioned by user ID, ensuring complete data '
        'isolation and enabling straightforward security rules. The Firestore database uses a nested '
        'collection model under each user, while Firebase Storage organizes files by document ID with '
        'separate paths for originals, thumbnails, PDFs, and signatures.'
    ))

    story.append(add_heading('5.1 Firestore Collections', h2_style, level=1))
    fs_data = [
        [HP('Collection Path'), HP('Purpose'), HP('Key Fields')],
        [CP('users/{uid}'), CP('User profile and preferences'), CP('name, email, isPremium, syncEnabled')],
        [CP('users/{uid}/documents/{docId}'), CP('Document metadata and sync state'), CP('title, filePath, syncStatus, updatedAt')],
        [CP('users/{uid}/folders/{folderId}'), CP('Folder hierarchy and organization'), CP('name, parentId, color, icon')],
        [CP('users/{uid}/tags/{tagId}'), CP('Tag definitions for categorization'), CP('name, color')],
        [CP('users/{uid}/sync_log/{logId}'), CP('Sync operation history and audit trail'), CP('operation, timestamp, status')],
    ]
    story.append(Spacer(1, 12))
    story.append(make_table(fs_data, col_ratios=[0.32, 0.35, 0.33]))
    story.append(Spacer(1, 12))

    story.append(add_heading('5.2 Firebase Storage Paths', h2_style, level=1))
    storage_data = [
        [HP('Storage Path'), HP('Content Type'), HP('Description')],
        [CP('users/{uid}/documents/{docId}/original.jpg'), CC('JPEG'), CP('Original scanned image at full resolution')],
        [CP('users/{uid}/documents/{docId}/thumbnail.jpg'), CC('JPEG'), CP('Compressed thumbnail for list views')],
        [CP('users/{uid}/documents/{docId}/pdf/{filename}.pdf'), CC('PDF'), CP('Generated PDF document file')],
        [CP('users/{uid}/signatures/{sigId}.png'), CC('PNG'), CP('User signature image with transparency')],
    ]
    story.append(make_table(storage_data, col_ratios=[0.38, 0.12, 0.50]))
    story.append(Spacer(1, 12))

    story.append(add_heading('5.3 Authentication Configuration', h2_style, level=1))
    story.append(P(
        'Firebase Authentication supports multiple sign-in methods including email/password, Google Sign-In, '
        'and anonymous authentication for trial users. The authentication flow uses Firebase Auth state '
        'listeners to automatically detect sign-in/sign-out events and update the UI accordingly. Custom '
        'auth tokens are generated for premium feature access, and the auth UID serves as the primary key '
        'for all user-scoped Firestore collections and Storage paths. Security rules enforce that users can '
        'only access their own data, preventing any cross-user data leakage.'
    ))

    story.append(add_heading('5.4 Security Rules', h2_style, level=1))
    story.append(P(
        'Firestore security rules enforce user-scoped access: every read and write operation must authenticate '
        'the user and verify that the requested resource belongs to them. Rules validate data types and '
        'required fields on write operations, preventing malformed data from entering the database. Storage '
        'rules restrict file uploads to authenticated users and enforce size limits (10MB for images, 50MB '
        'for PDFs). Download access is similarly restricted to the owning user. All security rules are '
        'deployed via Firebase CLI and tested with the Firestore emulator before production deployment.'
    ))
    story.append(Spacer(1, 18))

    # ═══════════════════════════════════════════════════════════
    # SECTION 6: Riverpod Setup
    # ═══════════════════════════════════════════════════════════
    story.extend(add_major_section('6. Riverpod Setup'))
    story.append(P(
        'ScanPro uses Riverpod (flutter_riverpod: ^2.5.1) as its state management solution, chosen for its '
        'compile-time safety, testability, and decoupled architecture that doesn\'t depend on the widget tree. '
        'The provider hierarchy follows a layered approach that mirrors the Clean Architecture layers, with '
        'each provider having a clearly defined scope and responsibility. Riverpod\'s code generation '
        'capabilities (riverpod_annotation: ^2.3.5) reduce boilerplate and provide type-safe provider '
        'definitions that catch errors at compile time rather than runtime.'
    ))

    story.append(add_heading('6.1 Provider Hierarchy', h2_style, level=1))
    story.append(P(
        'The provider hierarchy is organized into three tiers. At the foundation are infrastructure providers '
        'that create and configure singletons like Hive boxes, Firebase instances, and HTTP clients. Above '
        'these sit repository providers that implement domain repository interfaces using infrastructure '
        'dependencies. At the top are feature-specific providers (StateNotifierProviders and AsyncNotifiers) '
        'that coordinate use cases and expose reactive state to the UI. Each feature module defines its own '
        'provider scope, and cross-feature communication happens through shared repository providers rather '
        'than direct provider imports, maintaining loose coupling between features.'
    ))

    story.append(add_heading('6.2 StateNotifier Pattern', h2_style, level=1))
    story.append(P(
        'Each feature page uses a StateNotifierProvider with a dedicated state class. The state class is '
        'immutable and uses the copyWith pattern for state transitions. For example, the ScannerNotifier '
        'manages ScannerState which includes the current scan mode, captured images list, edge detection '
        'results, and processing status. All state mutations go through the notifier\'s methods, which '
        'delegate to use cases and emit new states. This pattern ensures that state transitions are '
        'predictable, testable, and traceable. Async operations use AsyncValue to represent loading, data, '
        'and error states, with built-in support for pull-to-refresh and automatic error recovery.'
    ))

    story.append(add_heading('6.3 Dependency Injection Approach', h2_style, level=1))
    story.append(P(
        'Dependency injection is handled entirely through Riverpod providers, eliminating the need for a '
        'separate DI container. The di/injection.dart file serves as the composition root where all '
        'providers are assembled. Each DI module (scanner_module.dart, ocr_module.dart, etc.) defines '
        'the providers for its feature, creating a clear dependency graph. Provider overrides enable easy '
        'testing by replacing real implementations with mocks. The ProviderScope is created in main.dart '
        'with any necessary overrides for environment-specific configurations like API keys and feature flags.'
    ))
    story.append(Spacer(1, 18))

    # ═══════════════════════════════════════════════════════════
    # SECTION 7: Navigation System
    # ═══════════════════════════════════════════════════════════
    story.extend(add_major_section('7. Navigation System'))
    story.append(P(
        'ScanPro uses GoRouter (go_router: ^14.2.0) as its declarative routing solution, providing type-safe '
        'route definitions, deep link support, and nested navigation capabilities. GoRouter was selected over '
        'Flutter\'s built-in Navigator 2.0 for its simpler API, built-in redirect support for authentication '
        'guarding, and first-class support for deep links and URL-based navigation. The router configuration '
        'is centralized in a single location, making it easy to understand the entire navigation graph at a glance.'
    ))

    story.append(add_heading('7.1 Route Configuration', h2_style, level=1))
    route_data = [
        [HP('Route Path'), HP('Screen'), HP('Parameters')],
        [CP('/'), CC('HomeScreen'), CP('None')],
        [CP('/scanner'), CC('CameraScreen'), CP('None')],
        [CP('/scanner/crop'), CC('CropScreen'), CP('imagePath')],
        [CP('/scanner/enhance'), CC('EnhanceScreen'), CP('imagePath')],
        [CP('/scanner/batch'), CC('BatchScanScreen'), CP('None')],
        [CP('/documents'), CC('DocumentsScreen'), CP('folderId (optional)')],
        [CP('/documents/:id'), CC('DocumentDetailScreen'), CP('documentId')],
        [CP('/documents/trash'), CC('TrashScreen'), CP('None')],
        [CP('/pdf/viewer'), CC('PdfViewerScreen'), CP('pdfPath')],
        [CP('/pdf/merge'), CC('PdfMergeScreen'), CP('None')],
        [CP('/pdf/split'), CC('PdfSplitScreen'), CP('pdfPath')],
        [CP('/pdf/compress'), CC('PdfCompressScreen'), CP('pdfPath')],
        [CP('/pdf/editor'), CC('PdfEditorScreen'), CP('pdfPath')],
        [CP('/settings'), CC('SettingsScreen'), CP('None')],
        [CP('/profile'), CC('ProfileScreen'), CP('None')],
        [CP('/lock'), CC('LockScreen'), CP('None')],
    ]
    story.append(Spacer(1, 12))
    story.append(make_table(route_data, col_ratios=[0.28, 0.32, 0.40]))
    story.append(Spacer(1, 12))

    story.append(add_heading('7.2 Deep Links & Route Guards', h2_style, level=1))
    story.append(P(
        'Deep links are configured for key user flows: opening a specific document (scanpro://documents/{id}), '
        'starting a scan (scanpro://scanner), and sharing content from other apps. Android intent filters '
        'are registered in AndroidManifest.xml to handle these custom URL schemes. Route guards implement '
        'authentication checking and biometric lock verification. The GoRouter redirect function checks '
        'the authentication state before allowing access to protected routes, redirecting unauthenticated '
        'users to the login screen. Additionally, a biometric guard intercepts navigation when the app '
        'returns from background, requiring re-authentication before resuming.'
    ))
    story.append(Spacer(1, 18))

    # ═══════════════════════════════════════════════════════════
    # SECTION 8: Scanner Engine Design
    # ═══════════════════════════════════════════════════════════
    story.extend(add_major_section('8. Scanner Engine Design'))
    story.append(P(
        'The Scanner Engine is the foundational component of ScanPro, responsible for capturing document images, '
        'detecting document boundaries, performing perspective correction, and applying image enhancement. It '
        'combines Flutter\'s camera plugin with OpenCV (via opencv_dart) for computer vision processing, '
        'delivering professional-quality scan results that rival dedicated hardware scanners. The engine is '
        'designed for real-time processing with a pipeline architecture that minimizes latency between capture '
        'and final output.'
    ))

    story.append(add_heading('8.1 Camera Controller', h2_style, level=1))
    story.append(P(
        'The camera controller wraps the camera package (^0.11.0) and provides a high-level API for document '
        'scanning. It manages camera initialization, resolution configuration (favoring 4K when available), '
        'focus control with continuous auto-focus optimized for documents, and flash management. The controller '
        'exposes a real-time image stream that feeds into the edge detection pipeline. A frame rate limiter '
        'throttles processing to 15fps to balance detection responsiveness with battery life. The camera '
        'controller also handles multi-camera selection, preferring the ultra-wide lens for document capture '
        'when available, and managing camera permissions with graceful degradation.'
    ))

    story.append(add_heading('8.2 OpenCV Integration', h2_style, level=1))
    story.append(P(
        'OpenCV integration is handled through the opencv_dart package (^1.0.0), which provides Dart bindings '
        'for core OpenCV functions via FFI. The integration focuses on image processing functions including '
        'Canny edge detection, contour finding, perspective transformation (getPerspectiveTransform and '
        'warpPerspective), adaptive thresholding, and morphological operations. All OpenCV operations run on '
        'background isolates to prevent UI jank, with results communicated back to the main isolate via ports. '
        'The OpenCV datasource abstracts the low-level FFI calls, providing a clean API for the edge detection '
        'and image processing services.'
    ))

    story.append(add_heading('8.3 Edge Detection Algorithm', h2_style, level=1))
    story.append(P(
        'The edge detection algorithm operates in real-time on the camera feed. It begins by converting the '
        'frame to grayscale and applying Gaussian blur to reduce noise. Canny edge detection identifies edges, '
        'and contour analysis finds the largest quadrilateral contour. The algorithm uses a scoring system that '
        'considers contour area, convexity, and aspect ratio to select the most likely document boundary. '
        'Douglas-Peucker approximation simplifies the contour to four corners. A confidence score is computed '
        'based on contour quality metrics, and only contours above a threshold are displayed to the user. The '
        'auto-capture feature triggers when a high-confidence contour remains stable for 1.5 seconds.'
    ))

    story.append(add_heading('8.4 Perspective Correction & Enhancement Pipeline', h2_style, level=1))
    story.append(P(
        'Once the document boundary is confirmed, perspective correction applies a homography transformation '
        'using the four detected corners as source points and a rectangular target as the destination. This '
        'produces a geometrically corrected document image. The enhancement pipeline then processes the '
        'corrected image through multiple stages: adaptive histogram equalization for contrast, unsharp '
        'masking for sharpness, and color correction based on the selected enhancement mode. Available modes '
        'include Auto (AI-optimized), Vivid (saturated colors for presentations), Grayscale (for text '
        'documents), and Original (no processing). The pipeline uses a chain-of-responsibility pattern, '
        'allowing each enhancement step to modify or skip processing based on the document characteristics.'
    ))
    story.append(Spacer(1, 18))

    # ═══════════════════════════════════════════════════════════
    # SECTION 9: OCR Engine Design
    # ═══════════════════════════════════════════════════════════
    story.extend(add_major_section('9. OCR Engine Design'))
    story.append(P(
        'The OCR Engine provides on-device text recognition using Google ML Kit, enabling ScanPro to extract '
        'text from scanned documents without requiring an internet connection. The engine supports multiple '
        'languages, provides confidence scoring, and detects smart actions within recognized text. OCR results '
        'are stored locally in the OCRResult Hive model and indexed in the SearchIndex for full-text search. '
        'The OCR processing pipeline is designed to handle documents of varying quality, automatically applying '
        'pre-processing to improve recognition accuracy.'
    ))

    story.append(add_heading('9.1 Google ML Kit Integration', h2_style, level=1))
    story.append(P(
        'ScanPro integrates three ML Kit capabilities: Text Recognition (google_mlkit_text_recognition: ^0.12.0) '
        'for extracting text from images, Language Identification (google_mlkit_language_id: ^0.11.0) for '
        'detecting the language of recognized text, and Translation (google_mlkit_translation: ^0.11.0) for '
        'translating text between languages. All three run entirely on-device, ensuring privacy and offline '
        'functionality. The text recognizer supports both Latin and CJK scripts with high accuracy, and the '
        'language identifier can distinguish between over 100 languages. The translation capability downloads '
        'language models on-demand and caches them for offline use.'
    ))

    story.append(add_heading('9.2 Text Extraction Pipeline', h2_style, level=1))
    story.append(P(
        'The text extraction pipeline follows a multi-stage process. First, the scanned image undergoes '
        'pre-processing including deskewing (if not already corrected by the scanner engine), binarization '
        'for text-heavy regions, and region-of-interest detection to focus on text areas. The pre-processed '
        'image is then passed to the ML Kit text recognizer, which returns structured text blocks, lines, '
        'and elements with bounding boxes and confidence scores. Post-processing merges fragmented text '
        'blocks into coherent paragraphs, corrects common OCR errors using a dictionary-based approach, '
        'and computes an overall confidence score. The final result is stored in the OCRResult model with '
        'both the raw and processed text, enabling search indexing and smart action detection.'
    ))

    story.append(add_heading('9.3 Smart Action Detection', h2_style, level=1))
    story.append(P(
        'Smart action detection scans the OCR output for actionable content patterns: phone numbers (using '
        'libphonenumber formatting), email addresses (RFC 5322 regex), URLs (with protocol detection), '
        'physical addresses (using address pattern matching), dates and times (natural language parsing), '
        'and monetary amounts. Each detected action includes its type, the matched text, bounding box '
        'coordinates (for highlighting in the UI), and a tap handler that launches the appropriate system '
        'action (dialer for phone numbers, mail client for emails, browser for URLs, maps for addresses). '
        'This feature transforms static scanned documents into interactive, actionable content.'
    ))
    story.append(Spacer(1, 18))

    # ═══════════════════════════════════════════════════════════
    # SECTION 10: PDF Engine Design
    # ═══════════════════════════════════════════════════════════
    story.extend(add_major_section('10. PDF Engine Design'))
    story.append(P(
        'The PDF Engine provides comprehensive PDF manipulation capabilities using Syncfusion Flutter PDF '
        '(syncfusion_flutter_pdf: ^25.1.35) for creation and editing, and Syncfusion PDF Viewer '
        '(syncfusion_flutter_pdfviewer: ^25.1.35) for rendering. The engine supports the complete PDF '
        'lifecycle: creation from scanned images, viewing with annotation support, merging multiple PDFs, '
        'splitting by page ranges, compression for size reduction, and page-level editing. All operations '
        'are performed locally on the device, ensuring privacy and offline availability.'
    ))

    story.append(add_heading('10.1 PDF Creation', h2_style, level=1))
    story.append(P(
        'PDF creation converts scanned images into multi-page PDF documents. The engine supports creating '
        'PDFs from a single image, multiple images (batch scan), or by importing existing files via the '
        'file_picker plugin. Each page is configured with A4 or Letter size, and images are scaled and '
        'centered with configurable margins. The PDF metadata includes title, author, creation date, and '
        'a unique document ID for tracking. OCR text is embedded as an invisible text layer behind the '
        'image, making the PDF searchable in standard PDF readers while preserving the visual fidelity of '
        'the original scan. Page numbering and custom watermarks can be optionally applied during creation.'
    ))

    story.append(add_heading('10.2 Merge, Split & Compress Operations', h2_style, level=1))
    pdf_ops_data = [
        [HP('Operation'), HP('Input'), HP('Output'), HP('Key Features')],
        [CP('Merge'), CP('2+ PDF files'), CP('Single combined PDF'),
         CP('Custom page ordering, duplicate removal, bookmark merging')],
        [CP('Split'), CP('Single PDF'), CP('Multiple PDFs'),
         CP('By page range, by bookmark, or individual pages')],
        [CP('Compress'), CP('Single PDF'), CP('Smaller PDF'),
         CP('Image resampling, font subsetting, metadata stripping')],
        [CP('Extract'), CP('Single PDF'), CP('Selected pages'),
         CP('Page range selection, rotation during extraction')],
    ]
    story.append(Spacer(1, 12))
    story.append(make_table(pdf_ops_data, col_ratios=[0.12, 0.18, 0.20, 0.50]))
    story.append(Spacer(1, 12))

    story.append(add_heading('10.3 Page Management', h2_style, level=1))
    story.append(P(
        'The PDF editor provides drag-and-drop page reordering, page rotation (90, 180, 270 degrees), '
        'page deletion, and page insertion from other PDFs or images. The editor uses a thumbnail-based '
        'interface where each page is represented by a preview image that can be manipulated via standard '
        'gesture controls. Changes are tracked in an edit stack that supports undo/redo operations. The '
        'editor maintains a working copy of the PDF in a temporary directory, only overwriting the original '
        'when the user explicitly saves. This non-destructive editing approach ensures that accidental edits '
        'can always be reverted, and the original document is never permanently altered without confirmation.'
    ))
    story.append(Spacer(1, 18))

    # ═══════════════════════════════════════════════════════════
    # SECTION 11: AI Engine Design
    # ═══════════════════════════════════════════════════════════
    story.extend(add_major_section('11. AI Engine Design'))
    story.append(P(
        'The AI Engine integrates Google Gemini (google_generative_ai: ^0.4.0) to provide intelligent '
        'document processing capabilities that go far beyond simple OCR. The engine operates on OCR-extracted '
        'text and document metadata to deliver features like summarization, key point extraction, smart '
        'renaming, auto-categorization, tag generation, translation, and structured data extraction. All AI '
        'features require an internet connection and are gated behind the premium subscription tier, though '
        'a limited number of free uses are provided for trial purposes.'
    ))

    story.append(add_heading('11.1 Gemini API Integration', h2_style, level=1))
    story.append(P(
        'The Gemini API integration uses the Gemini 1.5 Flash model for fast, cost-effective inference on '
        'document processing tasks. The API client is configured with retry logic (3 attempts with exponential '
        'backoff), request timeout handling (30 seconds), and rate limiting to stay within quota. Each AI '
        'feature is implemented as a separate prompt template with carefully engineered system instructions '
        'that include few-shot examples for consistent output formatting. Responses are parsed using a '
        'structured output approach where the model returns JSON that is validated against expected schemas '
        'before being consumed by the application.'
    ))

    ai_features_data = [
        [HP('Feature'), HP('Description'), HP('Prompt Strategy')],
        [CP('Document Summary'), CP('Generates a concise 2-3 sentence summary'), CP('Extractive then abstractive approach')],
        [CP('Key Point Extraction'), CP('Lists 3-5 key points or action items'), CP('Structured bullet point output')],
        [CP('Smart Rename'), CP('Suggests descriptive filename'), CP('Format: date_type_subject convention')],
        [CP('Auto-Categorization'), CP('Assigns document to a category'), CP('Classification from predefined categories')],
        [CP('Tag Generation'), CP('Creates 3-5 relevant tags'), CP('Controlled vocabulary with synonyms')],
        [CP('Translation'), CP('Translates text to target language'), CP('Context-aware with domain terminology')],
        [CP('Data Extraction'), CP('Extracts structured data from forms'), CP('JSON schema-driven extraction')],
    ]
    story.append(Spacer(1, 12))
    story.append(make_table(ai_features_data, col_ratios=[0.22, 0.38, 0.40]))
    story.append(Spacer(1, 18))

    # ═══════════════════════════════════════════════════════════
    # SECTION 12: Sync Engine Design
    # ═══════════════════════════════════════════════════════════
    story.extend(add_major_section('12. Sync Engine Design'))
    story.append(P(
        'The Sync Engine implements an offline-first synchronization architecture using Firebase Firestore and '
        'Firebase Storage as the remote backend. The engine is designed to handle intermittent connectivity '
        'gracefully, queuing local changes for upload when network becomes available and resolving conflicts '
        'that arise from concurrent modifications on different devices. The sync process uses a delta-based '
        'approach that only transfers changed data, minimizing bandwidth usage and sync time.'
    ))

    story.append(add_heading('12.1 Offline-First Pattern', h2_style, level=1))
    story.append(P(
        'The offline-first pattern ensures that all document operations (create, update, delete) work without '
        'network connectivity. Local changes are immediately persisted to Hive and a corresponding SyncRecord '
        'is created with pending status. A background sync worker (managed by workmanager: ^0.5.2) periodically '
        'checks for pending SyncRecords and attempts to push them to Firebase. Firestore\'s offline persistence '
        'is enabled for metadata, providing seamless access to previously synced document metadata even when '
        'offline. File uploads (images and PDFs) are queued and uploaded sequentially when connectivity is '
        'restored, with progress tracking and automatic resume on failure.'
    ))

    story.append(add_heading('12.2 Conflict Resolution', h2_style, level=1))
    story.append(P(
        'Conflict resolution follows a "last write wins" strategy with a server-assigned timestamp as the '
        'tiebreaker. When a client pushes a change that conflicts with a newer server version, the sync engine '
        'compares timestamps and preserves the most recent modification. If the local change is older, it is '
        'discarded and the server version is applied locally. If the local change is newer, it overwrites the '
        'server version. In cases where data loss is possible (e.g., both versions have substantial changes), '
        'the engine creates a conflict entry in the SyncRecord with the conflicting server data preserved, '
        'allowing the user to manually resolve the conflict through the UI. This approach balances automatic '
        'resolution with user control over important data.'
    ))

    story.append(add_heading('12.3 Delta Sync', h2_style, level=1))
    story.append(P(
        'Delta sync minimizes data transfer by only syncing records that have changed since the last '
        'successful sync. Each SyncRecord includes a timestamp, and the client tracks the lastSyncAt value '
        'in the UserProfile. During sync, the client queries Firestore for documents with updatedAt greater '
        'than lastSyncAt, downloads only the changed records, and applies them to the local Hive database. '
        'File-level delta sync uses hash comparison: if the file hash matches between local and remote, the '
        'file transfer is skipped entirely. This approach reduces typical sync operations from minutes to '
        'seconds, even for users with hundreds of documents.'
    ))
    story.append(Spacer(1, 18))

    # ═══════════════════════════════════════════════════════════
    # SECTION 13: Security Module Design
    # ═══════════════════════════════════════════════════════════
    story.extend(add_major_section('13. Security Module Design'))
    story.append(P(
        'The Security Module provides multi-layered protection for user documents, combining device-level '
        'authentication, application-level access control, and data-level encryption. Security is treated as '
        'a first-class feature, not an afterthought, with every component designed to protect sensitive '
        'documents from unauthorized access. The module integrates with platform security APIs for biometric '
        'authentication and secure key storage, while providing user-configurable privacy controls that '
        'balance security with convenience.'
    ))

    story.append(add_heading('13.1 Biometric Authentication', h2_style, level=1))
    story.append(P(
        'Biometric authentication uses the local_auth package (^2.2.0) to support fingerprint, face '
        'recognition, and iris scanning depending on device capabilities. The app can be configured to '
        'require biometric authentication on launch, when returning from background, or when accessing '
        'specific documents. A fallback PIN is required during biometric setup for devices where biometric '
        'hardware is unavailable or fails. The biometric check is implemented as a GoRouter redirect guard, '
        'intercepting navigation when authentication is required and presenting the system biometric prompt '
        'before allowing access. Failed attempts are tracked with exponential backoff, and after 5 failed '
        'attempts, a mandatory 30-second cooldown is enforced.'
    ))

    story.append(add_heading('13.2 PIN Lock & Encryption', h2_style, level=1))
    story.append(P(
        'The PIN lock feature provides an alternative to biometric authentication, using a 4-6 digit PIN '
        'that is hashed using SHA-256 with a random salt and stored in flutter_secure_storage (^9.2.0). '
        'The secure storage uses Android Keystore on Android, ensuring that the PIN hash is protected by '
        'hardware-backed security. Document encryption uses AES-256-GCM via the encrypt package (^5.0.3), '
        'with encryption keys derived from the user\'s authentication credentials using PBKDF2 with 100,000 '
        'iterations. Encrypted documents are transparently decrypted on access and re-encrypted on save, '
        'with encryption applied at the file level so that individual documents can have different encryption '
        'keys. The encryption key management uses a master key stored in secure storage, with per-document '
        'keys encrypted under the master key.'
    ))

    story.append(add_heading('13.3 Secure Storage & Privacy Controls', h2_style, level=1))
    story.append(P(
        'Secure storage is implemented using flutter_secure_storage for sensitive data (authentication tokens, '
        'encryption keys, PIN hashes) and Hive for non-sensitive data (preferences, UI state). Privacy '
        'controls allow users to configure which data is synced to the cloud, enable/disable OCR text '
        'storage, manage AI feature permissions, and delete all cloud data on demand. The app includes a '
        "privacy dashboard that shows what data is stored locally and remotely, with one-tap options to clear "
        'specific data categories. All network communication uses TLS 1.3, and API keys are stored in '
        'environment-specific configurations rather than hardcoded in the source code.'
    ))
    story.append(Spacer(1, 18))

    # ═══════════════════════════════════════════════════════════
    # SECTION 14: UI/UX Design System
    # ═══════════════════════════════════════════════════════════
    story.extend(add_major_section('14. UI/UX Design System'))
    story.append(P(
        'ScanPro implements a comprehensive design system built on Material 3 (Material You), providing '
        'a consistent visual language across all screens and components. The design system defines color '
        'tokens, typography scale, spacing constants, elevation levels, and motion specifications that '
        'ensure visual coherence throughout the application. Every UI component is derived from the design '
        'system tokens, enabling theme switching (light/dark mode) and responsive layout adaptation with '
        'zero code duplication.'
    ))

    story.append(add_heading('14.1 Material 3 Theming', h2_style, level=1))
    story.append(P(
        'The theme system uses Material 3\'s dynamic color scheme with a seed color derived from the ScanPro '
        'brand palette. The ThemeExtension API defines custom color tokens and component styles that extend '
        'the base Material 3 theme. Both light and dark color schemes are generated from the same seed color '
        'using the ColorScheme.fromSeed method, ensuring perceptual consistency across modes. The theme '
        'configuration includes custom shapes, elevation overlays, and component themes that override default '
        'Material 3 styles to match ScanPro\'s design language. Typography follows the Material 3 type scale '
        'with custom font families (Inter for UI, Times New Roman for document previews).'
    ))

    story.append(add_heading('14.2 Dark/Light Mode & Responsive Layouts', h2_style, level=1))
    story.append(P(
        'Dark mode support is built into every component through the design system\'s token-based approach. '
        'Colors are never referenced directly; instead, semantic tokens (surface, onSurface, primary, etc.) '
        'resolve to different values based on the current brightness. The app follows the system brightness '
        'setting by default with an option to override. Responsive layouts use a breakpoint system: compact '
        '(phone, width < 600dp), medium (tablet portrait, 600-840dp), and expanded (tablet landscape, '
        '> 840dp). The scanner screen uses a different layout in expanded mode with a side panel for settings '
        'and recent scans, while the document list switches from a list view to a grid view at the medium '
        'breakpoint.'
    ))

    story.append(add_heading('14.3 Animation System & Component Library', h2_style, level=1))
    story.append(P(
        'The animation system uses flutter_animate (^4.5.0) for declarative, chainable animations that are '
        'consistent and performant. Standard motion patterns include fade-in for screen transitions, slide-up '
        'for modal sheets, scale for card interactions, and shimmer for loading states. All animations respect '
        'the system accessibility setting for reduced motion, falling back to instant state changes when '
        'reduced motion is enabled. The component library provides 30+ custom widgets built on the design '
        'system tokens: DocumentCard, ScanButton, EnhancementChip, FolderTile, TagPill, SearchBar, '
        'ProgressIndicator, and more. Each widget includes light/dark variants, responsive sizing, and '
        'animation support, ensuring that new screens can be composed from existing components without '
        'inconsistency.'
    ))
    story.append(Spacer(1, 18))

    # ═══════════════════════════════════════════════════════════
    # SECTION 15: Dependencies List
    # ═══════════════════════════════════════════════════════════
    story.extend(add_major_section('15. Dependencies List'))
    story.append(P(
        'ScanPro manages its dependencies through pubspec.yaml with strict version constraints using the caret '
        'syntax. The dependency list is organized by functional category and includes both production '
        'dependencies and dev dependencies for testing and code generation. All dependencies are evaluated '
        'for maintenance activity, license compatibility, and bundle size impact before inclusion. The '
        'application follows a policy of minimal dependencies, preferring platform APIs and custom '
        'implementations over third-party packages where feasible.'
    ))

    dep_data = [
        [HP('Package'), HP('Version'), HP('Purpose')],
        [CP('flutter'), CC('sdk'), CP('Core Flutter framework')],
        [CP('flutter_riverpod'), CC('^2.5.1'), CP('State management')],
        [CP('riverpod_annotation'), CC('^2.3.5'), CP('Code generation for providers')],
        [CP('go_router'), CC('^14.2.0'), CP('Declarative routing')],
        [CP('hive'), CC('^2.2.3'), CP('Local NoSQL database')],
        [CP('hive_flutter'), CC('^1.1.0'), CP('Hive Flutter integration')],
        [CP('firebase_core'), CC('^3.0.0'), CP('Firebase initialization')],
        [CP('firebase_auth'), CC('^5.0.0'), CP('Authentication service')],
        [CP('cloud_firestore'), CC('^5.0.0'), CP('Cloud database')],
        [CP('firebase_storage'), CC('^12.0.0'), CP('Cloud file storage')],
        [CP('google_mlkit_text_recognition'), CC('^0.12.0'), CP('On-device OCR')],
        [CP('google_mlkit_language_id'), CC('^0.11.0'), CP('Language detection')],
        [CP('google_mlkit_translation'), CC('^0.11.0'), CP('On-device translation')],
        [CP('syncfusion_flutter_pdf'), CC('^25.1.35'), CP('PDF creation and editing')],
        [CP('syncfusion_flutter_pdfviewer'), CC('^25.1.35'), CP('PDF rendering and viewing')],
        [CP('camera'), CC('^0.11.0'), CP('Camera hardware access')],
        [CP('image_picker'), CC('^1.1.0'), CP('Gallery image selection')],
        [CP('opencv_dart'), CC('^1.0.0'), CP('Computer vision processing')],
        [CP('google_generative_ai'), CC('^0.4.0'), CP('Gemini AI integration')],
        [CP('local_auth'), CC('^2.2.0'), CP('Biometric authentication')],
        [CP('flutter_secure_storage'), CC('^9.2.0'), CP('Encrypted key-value storage')],
        [CP('encrypt'), CC('^5.0.3'), CP('AES encryption')],
        [CP('path_provider'), CC('^2.1.3'), CP('File system paths')],
        [CP('uuid'), CC('^4.4.0'), CP('UUID generation')],
        [CP('intl'), CC('^0.19.0'), CP('Internationalization and formatting')],
        [CP('share_plus'), CC('^9.0.0'), CP('System sharing sheet')],
        [CP('file_picker'), CC('^8.0.0'), CP('File selection from storage')],
        [CP('permission_handler'), CC('^11.3.1'), CP('Runtime permission management')],
        [CP('connectivity_plus'), CC('^6.0.3'), CP('Network connectivity detection')],
        [CP('flutter_animate'), CC('^4.5.0'), CP('Declarative animations')],
        [CP('cached_network_image'), CC('^3.3.1'), CP('Cached image loading')],
        [CP('photo_manager'), CC('^3.2.0'), CP('Photo gallery access')],
        [CP('mobile_scanner'), CC('^5.1.0'), CP('QR/barcode scanning')],
        [CP('workmanager'), CC('^0.5.2'), CP('Background task scheduling')],
        [CP('flutter_local_notifications'), CC('^17.1.0'), CP('Local notification display')],
    ]
    story.append(Spacer(1, 12))
    story.append(make_table(dep_data, col_ratios=[0.35, 0.12, 0.53]))
    story.append(Spacer(1, 18))

    # ═══════════════════════════════════════════════════════════
    # SECTION 16: Android Permissions
    # ═══════════════════════════════════════════════════════════
    story.extend(add_major_section('16. Android Permissions'))
    story.append(P(
        'ScanPro requires specific Android permissions to access device hardware (camera, biometric sensors) '
        'and user data (photos, files, network). All permissions are declared in the AndroidManifest.xml file '
        'and are requested at runtime using the permission_handler package, following Android\'s permission '
        'best practices. Permissions are requested only when the user navigates to a feature that requires '
        'them, with clear explanations provided before each request. The application gracefully handles '
        'permission denials by offering alternative functionality or guiding users to settings.'
    ))

    perm_data = [
        [HP('Permission'), HP('Manifest Declaration'), HP('Purpose'), HP('Request Timing')],
        [CP('Camera'), CC('CAMERA'), CP('Document scanning capture'), CP('On first scanner launch')],
        [CP('Storage Read'), CC('READ_EXTERNAL_STORAGE'), CP('Import files from gallery'), CP('On gallery import')],
        [CP('Storage Write'), CC('WRITE_EXTERNAL_STORAGE'), CP('Save scanned documents'), CP('On first save')],
        [CP('Media Images'), CC('READ_MEDIA_IMAGES'), CP('Android 13+ image access'), CP('On gallery import')],
        [CP('Internet'), CC('INTERNET'), CP('Cloud sync and AI features'), CP('Always available')],
        [CP('Network State'), CC('ACCESS_NETWORK_STATE'), CP('Connectivity detection for sync'), CP('Always available')],
        [CP('Biometric'), CC('USE_BIOMETRIC'), CP('Fingerprint and face unlock'), CP('On security setup')],
        [CP('Vibrate'), CC('VIBRATE'), CP('Haptic feedback on capture'), CP('Always available')],
        [CP('Foreground Service'), CC('FOREGROUND_SERVICE'), CP('Background sync operations'), CP('On sync enable')],
        [CP('Post Notification'), CC('POST_NOTIFICATIONS'), CP('Sync completion alerts'), CP('On first sync')],
        [CP('Boot Completed'), CC('RECEIVE_BOOT_COMPLETED'), CP('Restart sync after reboot'), CP('Always available')],
    ]
    story.append(Spacer(1, 12))
    story.append(make_table(perm_data, col_ratios=[0.15, 0.25, 0.30, 0.30]))
    story.append(Spacer(1, 12))

    story.append(P(
        'Additional AndroidManifest.xml configurations include: hardware acceleration enabled for smooth '
        'camera preview, large heap allocation for image processing, request for legacy external storage '
        'flag for compatibility, file provider declaration for sharing documents, and intent filters for '
        'deep link handling. The manifest also declares the camera hardware feature as required, which '
        'filters the app from devices without cameras on the Play Store.'
    ))
    story.append(Spacer(1, 18))

    # ═══════════════════════════════════════════════════════════
    # SECTION 17: Build Configuration
    # ═══════════════════════════════════════════════════════════
    story.extend(add_major_section('17. Build Configuration'))
    story.append(P(
        'The build configuration manages compile-time settings, signing credentials, code optimization, '
        'and multi-flavor builds for different deployment environments. The configuration is split between '
        'the project-level build.gradle (Gradle wrapper version, repository sources, and plugin management) '
        'and the app-level build.gradle (SDK versions, signing, build types, and product flavors). Proper '
        'build configuration is essential for generating optimized, signed APKs and App Bundles for '
        'Play Store distribution.'
    ))

    story.append(add_heading('17.1 build.gradle Configuration', h2_style, level=1))
    build_data = [
        [HP('Setting'), HP('Value'), HP('Notes')],
        [CP('compileSdk'), CC('34'), CP('Latest Android SDK for API access')],
        [CP('minSdk'), CC('24'), CP('Android 7.0+ (ML Kit requirement)')],
        [CP('targetSdk'), CC('34'), CP('Latest Android behavior')],
        [CP('kotlin version'), CC('1.9.22'), CP('Kotlin compiler version')],
        [CP('NDK version'), CC('24.0.8215888'), CP('OpenCV native library support')],
        [CP('Java compatibility'), CC('1.8'), CP('JDK 8 source/target compatibility')],
    ]
    story.append(Spacer(1, 12))
    story.append(make_table(build_data, col_ratios=[0.25, 0.20, 0.55]))
    story.append(Spacer(1, 12))

    story.append(add_heading('17.2 Signing Configuration & Flavors', h2_style, level=1))
    story.append(P(
        'The signing configuration uses separate keystores for debug and release builds. The debug keystore '
        'is checked into version control for team sharing, while the release keystore is stored in a CI/CD '
        'secure variable and never committed. The signing config references environment variables '
        '(KEYSTORE_PATH, KEYSTORE_PASSWORD, KEY_ALIAS, KEY_PASSWORD) that are set by the CI pipeline. '
        'Product flavors include "development" (with debug logging, API staging endpoints, and debug banner) '
        'and "production" (with minimal logging, production API endpoints, and no debug indicators). Each '
        'flavor has a distinct applicationIdSuffix and versionNameSuffix for side-by-side installation.'
    ))

    story.append(add_heading('17.3 ProGuard Rules', h2_style, level=1))
    story.append(P(
        'ProGuard (R8) is enabled for release builds to reduce APK size and obfuscate code. Custom ProGuard '
        'rules preserve classes required by reflection-based libraries (Hive type adapters, Firebase models, '
        'Gson serialization). Specific keep rules are defined for: Hive adapter classes, Firebase data models, '
        'OpenCV native method signatures, and Syncfusion license validation classes. The ProGuard configuration '
        'is tested with each release build by running the full integration test suite on the obfuscated APK '
        'to catch any runtime class-not-found errors caused by over-aggressive shrinking.'
    ))
    story.append(Spacer(1, 18))

    # ═══════════════════════════════════════════════════════════
    # SECTION 18: MVP Roadmap
    # ═══════════════════════════════════════════════════════════
    story.extend(add_major_section('18. MVP Roadmap'))
    story.append(P(
        'The MVP phase spans 8 weeks and focuses on delivering the core document scanning experience: '
        'capture, enhance, organize, and sync. The roadmap is structured in weekly sprints with clear '
        'deliverables at each milestone. The MVP must demonstrate that ScanPro can replace a physical '
        'scanner for the most common use cases while providing a polished, intuitive user experience '
        'that distinguishes it from competitors.'
    ))

    mvp_data = [
        [HP('Week'), HP('Focus Area'), HP('Deliverables')],
        [CP('Week 1-2'), CP('Project Setup & Foundation'),
         CP('Architecture scaffolding, theme system, navigation, CI/CD pipeline, lint rules, '
            'Hive initialization, Firebase project setup, base widget library')],
        [CP('Week 3-4'), CP('Scanner Engine'),
         CP('Camera controller, real-time edge detection, auto-capture, perspective correction, '
            'image enhancement pipeline (auto/grayscale modes), gallery import, batch scan support')],
        [CP('Week 5-6'), CP('Core Document Features'),
         CP('PDF creation from scans, OCR text extraction with ML Kit, document list/grid view, '
            'folder management, tagging system, search by title and OCR text, favorites and archive')],
        [CP('Week 7-8'), CP('Cloud & Authentication'),
         CP('Firebase Auth (email/Google sign-in), Firestore sync for document metadata, Storage sync '
            'for files, offline-first pattern, sync status indicators, basic testing suite, bug fixes')],
    ]
    story.append(Spacer(1, 12))
    story.append(make_table(mvp_data, col_ratios=[0.12, 0.22, 0.66]))
    story.append(Spacer(1, 12))

    story.append(P(
        'At the end of the MVP phase, ScanPro will be a fully functional document scanner with cloud sync '
        'capabilities. Key success metrics for the MVP include: scan-to-PDF in under 10 seconds, OCR accuracy '
        'above 95% for English text, zero data loss during sync operations, and a crash-free rate above 99%. '
        'The MVP will be distributed to a closed beta group of 50 users for real-world testing and feedback '
        'collection before proceeding to the production roadmap phases.'
    ))
    story.append(Spacer(1, 18))

    # ═══════════════════════════════════════════════════════════
    # SECTION 19: Production Roadmap
    # ═══════════════════════════════════════════════════════════
    story.extend(add_major_section('19. Production Roadmap'))
    story.append(P(
        'The production roadmap extends ScanPro from an MVP scanner to a comprehensive document management '
        'platform with advanced features across three phases spanning months 3-12. Each phase builds on the '
        'previous one, adding capabilities that increase the application\'s value proposition and justify '
        'the premium subscription tier. The roadmap prioritizes features based on user feedback from the '
        'MVP beta, market analysis of competitor gaps, and technical dependencies between features.'
    ))

    story.append(add_heading('19.1 Phase 2 (Month 3): PDF Tools & Search', h2_style, level=1))
    story.append(P(
        'Phase 2 focuses on transforming ScanPro from a scanner into a PDF toolkit. The PDF merge feature '
        'allows combining multiple scanned documents into a single file with custom page ordering. The PDF '
        'split feature extracts specific pages or page ranges from existing documents. PDF compression '
        'reduces file sizes by 40-70% through image resampling and font subsetting, making documents easier '
        'to share via email and messaging apps. Advanced OCR capabilities include multi-language recognition '
        'with automatic language detection, table structure recognition that preserves cell layouts, and '
        'handwriting recognition for annotated documents. The search engine gets a significant upgrade with '
        'full-text search across all OCR content, fuzzy matching for typo tolerance, and filter combinations '
        'by date range, folder, tags, and document type.'
    ))

    story.append(add_heading('19.2 Phase 3 (Months 4-5): AI Features & Advanced Tools', h2_style, level=1))
    story.append(P(
        'Phase 3 introduces AI-powered features using the Gemini API integration. Document summarization '
        'generates concise overviews of lengthy documents, while key point extraction identifies the most '
        'important information. Smart rename automatically generates descriptive filenames based on document '
        'content, and auto-categorization assigns documents to appropriate folders. Tag generation creates '
        'relevant tags from document content, and translation supports cross-language document processing. '
        'The signature system allows users to create, save, and apply digital signatures to documents. '
        'The annotations module supports highlighting, text notes, freehand drawing, and text boxes on PDF '
        'pages. A QR/barcode scanner (mobile_scanner: ^5.1.0) is added as a supplementary feature, allowing '
        'users to scan and organize QR codes alongside traditional documents.'
    ))

    story.append(add_heading('19.3 Phase 4 (Month 6+): Security & Enterprise', h2_style, level=1))
    story.append(P(
        'Phase 4 hardens the application for enterprise deployment and public release. The security module '
        'adds biometric authentication, PIN lock with configurable auto-lock timeout, AES-256 document '
        'encryption, and a privacy dashboard. Enterprise features include shared workspace folders with '
        'role-based access control, admin dashboards for team management, SSO integration via SAML/OIDC, '
        'and compliance reporting for regulated industries. Performance optimization targets include reducing '
        'app startup time to under 2 seconds, memory usage below 200MB during scanning, and battery '
        'consumption of less than 5% per hour of active scanning. The final step is Play Store preparation '
        'with store listing optimization, screenshot generation, privacy policy publication, and COPPA/GDPR '
        'compliance documentation. The target is Play Store launch by the end of month 8.'
    ))

    prod_data = [
        [HP('Phase'), HP('Timeline'), HP('Key Features'), HP('Success Metric')],
        [CP('Phase 2'), CC('Month 3'), CP('PDF merge/split/compress, advanced OCR, search engine'),
         CP('50% faster document workflows')],
        [CP('Phase 3'), CC('Months 4-5'), CP('AI features, signatures, annotations, QR scanner'),
         CP('30% premium conversion rate')],
        [CP('Phase 4'), CC('Month 6+'), CP('Security module, enterprise features, Play Store launch'),
         CP('10K downloads in first month')],
    ]
    story.append(Spacer(1, 12))
    story.append(make_table(prod_data, col_ratios=[0.12, 0.13, 0.42, 0.33]))
    story.append(Spacer(1, 18))

    # ═══════════════════════════════════════════════════════════
    # SECTION 20: Testing Strategy
    # ═══════════════════════════════════════════════════════════
    story.extend(add_major_section('20. Testing Strategy'))
    story.append(P(
        'ScanPro follows a comprehensive testing strategy that spans all levels of the testing pyramid: '
        'unit tests for business logic, widget tests for UI behavior, integration tests for end-to-end '
        'flows, and performance tests for critical paths. The testing infrastructure is built into the '
        'project from day one, not bolted on as an afterthought. Every feature module includes a '
        'corresponding test directory with test suites organized by architecture layer.'
    ))

    story.append(add_heading('20.1 Unit Testing', h2_style, level=1))
    story.append(P(
        'Unit tests cover all domain use cases, repository implementations, and service classes. The test '
        'framework uses Flutter\'s built-in test package with mockito for generating mocks and faker for '
        'creating test data. Each use case has at least 3 test cases: happy path, error handling, and edge '
        'cases. Repository tests verify data mapping between models and entities, cache invalidation logic, '
        'and error propagation. Service tests use mock implementations of platform APIs (camera, ML Kit, '
        'Firebase) to verify business logic in isolation. The target is 80% code coverage for the domain '
        'layer and 70% for the data layer. Tests run automatically on every pull request via GitHub Actions.'
    ))

    story.append(add_heading('20.2 Widget Testing', h2_style, level=1))
    story.append(P(
        'Widget tests verify UI behavior including rendering, user interactions, state transitions, and '
        'navigation. Each screen has a dedicated widget test file that tests the complete user interaction '
        'flow: initial rendering state, loading states, data states, and error states. Tests use Riverpod '
        'overrides to inject mock providers, ensuring tests are deterministic and fast. Key scenarios tested '
        'include: document list pagination, scanner capture flow, OCR result display, PDF viewer interaction, '
        'and settings persistence. Widget tests also verify accessibility by checking semantic labels, '
        'touch target sizes, and contrast ratios. The target is 60% widget code coverage.'
    ))

    story.append(add_heading('20.3 Integration & Performance Testing', h2_style, level=1))
    story.append(P(
        'Integration tests verify complete user flows across multiple screens and system components using '
        'Flutter\'s integration_test package. Key integration test scenarios include: full scan-to-sync '
        'workflow (capture, enhance, create PDF, upload to cloud), authentication and sync across app '
        'restarts, and document sharing via system intents. Integration tests run on real Android devices '
        'connected via USB, using Firebase emulator for backend services. Performance testing targets '
        'specific metrics: camera preview frame rate (target 30fps), OCR processing time (under 3 seconds '
        'per page), PDF generation speed (under 5 seconds for 10 pages), and memory usage during batch '
        'scanning (under 300MB). Performance benchmarks are tracked across releases to detect regressions, '
        'with alerts triggered when metrics degrade by more than 15% from the baseline.'
    ))

    test_data = [
        [HP('Test Type'), HP('Coverage Target'), HP('Tools'), HP('Run Frequency')],
        [CP('Unit Tests'), CC('80% domain, 70% data'), CP('flutter test, mockito, faker'), CP('Every PR')],
        [CP('Widget Tests'), CC('60% presentation'), CP('flutter test, riverpod overrides'), CP('Every PR')],
        [CP('Integration Tests'), CC('5 critical flows'), CP('integration_test, Firebase emulator'), CP('Nightly')],
        [CP('Performance Tests'), CC('4 key metrics'), CP('flutter drive, custom metrics'), CP('Weekly')],
    ]
    story.append(Spacer(1, 12))
    story.append(make_table(test_data, col_ratios=[0.18, 0.22, 0.32, 0.28]))
    story.append(Spacer(1, 18))

    return story


# ═══════════════════════════════════════════════════════════════
# MAIN EXECUTION
# ═══════════════════════════════════════════════════════════════
def main():
    print("=" * 60)
    print("ScanPro Architecture Document PDF Generator")
    print("=" * 60)

    # Step 1: Generate cover HTML
    print("\n[1/4] Generating cover HTML...")
    generate_cover_html()

    # Step 2: Render cover PDF via html2poster.js
    print("\n[2/4] Rendering cover PDF via html2poster.js...")
    html2poster_path = os.path.join(PDF_SKILL_DIR, 'scripts', 'html2poster.js')
    result = subprocess.run(
        ['node', html2poster_path, COVER_HTML, '--output', COVER_PDF, '--width', '794px'],
        capture_output=True, text=True, timeout=120
    )
    if result.returncode != 0:
        print(f"  WARNING: Cover rendering failed: {result.stderr}")
        print("  Proceeding without cover page...")
        COVER_PDF_EXISTS = False
    else:
        print(f"  Cover PDF generated: {COVER_PDF}")
        COVER_PDF_EXISTS = True

    # Step 3: Build body PDF with ReportLab
    print("\n[3/4] Building body PDF with ReportLab...")
    doc = TocDocTemplate(
        BODY_PDF,
        pagesize=A4,
        leftMargin=LEFT_MARGIN,
        rightMargin=RIGHT_MARGIN,
        topMargin=TOP_MARGIN,
        bottomMargin=BOTTOM_MARGIN,
        title='ScanPro Architecture Document',
        author='Z.ai',
        creator='Z.ai',
        subject='Technical Architecture Document for ScanPro Flutter Application',
    )

    # Page number footer
    def add_page_number(canvas, doc):
        canvas.saveState()
        canvas.setFont('Times New Roman', 9)
        canvas.setFillColor(TEXT_MUTED)
        page_num = canvas.getPageNumber()
        if page_num > 1:  # Skip page number on TOC page
            text = f"ScanPro Architecture Document  |  Page {page_num}"
            canvas.drawCentredString(PAGE_W / 2.0, 0.5 * inch, text)
        canvas.restoreState()

    story = build_story()
    doc.multiBuild(story, onLaterPages=add_page_number)
    print(f"  Body PDF generated: {BODY_PDF}")

    # Step 4: Merge cover + body PDF
    print("\n[4/4] Merging cover + body PDF...")
    from pypdf import PdfReader, PdfWriter, Transformation

    A4_W, A4_H = 595.28, 841.89

    def normalize_page_to_a4(page):
        box = page.mediabox
        w, h = float(box.width), float(box.height)
        if abs(w - A4_W) > 2 or abs(h - A4_H) > 2:
            sx, sy = A4_W / w, A4_H / h
            page.add_transformation(Transformation().scale(sx=sx, sy=sy))
            page.mediabox.lower_left = (0, 0)
            page.mediabox.upper_right = (A4_W, A4_H)
        return page

    writer = PdfWriter()

    if COVER_PDF_EXISTS and os.path.exists(COVER_PDF):
        cover_page = PdfReader(COVER_PDF).pages[0]
        writer.add_page(normalize_page_to_a4(cover_page))
        print("  Cover page added as page 1")

    for page in PdfReader(BODY_PDF).pages:
        writer.add_page(normalize_page_to_a4(page))

    writer.add_metadata({
        '/Title': 'ScanPro Architecture Document',
        '/Author': 'Z.ai',
        '/Creator': 'Z.ai',
        '/Subject': 'Technical Architecture Document for ScanPro Flutter Application',
    })

    with open(FINAL_PDF, 'wb') as f:
        writer.write(f)

    file_size = os.path.getsize(FINAL_PDF)
    page_count = len(PdfReader(FINAL_PDF).pages)
    print(f"\n{'=' * 60}")
    print(f"FINAL PDF: {FINAL_PDF}")
    print(f"Size: {file_size / 1024:.1f} KB")
    print(f"Pages: {page_count}")
    print(f"{'=' * 60}")

    # Cleanup temp files
    for tmp in [BODY_PDF, COVER_HTML, COVER_PDF]:
        try:
            os.remove(tmp)
        except:
            pass


if __name__ == '__main__':
    main()
