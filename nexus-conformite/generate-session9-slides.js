const pptxgen = require('pptxgenjs');
const fs = require('fs');

// Create presentation
const pres = new pptxgen();
pres.layout = 'LAYOUT_16x9';
pres.author = 'Claude (AI Assistant)';
pres.title = 'NEXUS CONFORMITÉ — Session 9';

// Color palette (Nexus BLUE)
const colors = {
  primary: "1B4F8A",    // Deep blue
  secondary: "2E6DA4",  // Medium blue
  accent: "F9E795",     // Gold accent
  light: "ECF0F5",      // Light blue
  dark: "1a1a1a",       // Dark text
  white: "FFFFFF"
};

// Slide 1: TITLE SLIDE
const slide1 = pres.addSlide();
slide1.background = { color: colors.primary };
slide1.addText("NEXUS CONFORMITÉ", {
  x: 0.5, y: 1.5, w: 9, h: 1.2,
  fontSize: 60, bold: true, color: colors.white,
  align: "center", fontFace: "Arial"
});
slide1.addText("Session #9 — Consolidation & Déploiement", {
  x: 0.5, y: 2.8, w: 9, h: 0.6,
  fontSize: 32, color: colors.accent,
  align: "center", fontFace: "Arial"
});
slide1.addText("01 Avril 2026", {
  x: 0.5, y: 4.2, w: 9, h: 0.4,
  fontSize: 20, color: colors.white,
  align: "center", italic: true
});
slide1.addText("Domaine acheté • Infrastructure Hostinger • Workflows vérifiés", {
  x: 0.5, y: 5.0, w: 9, h: 0.5,
  fontSize: 16, color: colors.light,
  align: "center"
});

// Slide 2: EXECUTIVE SUMMARY
const slide2 = pres.addSlide();
slide2.background = { color: colors.white };
slide2.addShape(pres.shapes.RECTANGLE, {
  x: 0, y: 0, w: 10, h: 0.8,
  fill: { color: colors.primary }
});
slide2.addText("Executive Summary", {
  x: 0.5, y: 0.15, w: 9, h: 0.5,
  fontSize: 44, bold: true, color: colors.white,
  fontFace: "Arial"
});

const summaryPoints = [
  { icon: "✅", text: "Domaine nexusconformite.fr acheté" },
  { icon: "✅", text: "Infrastructure basculée vers Hostinger" },
  { icon: "✅", text: "9 workflows vérifiés, aucun doublon JSON" },
  { icon: "✅", text: "3 documents maîtres créés (PROJECT, CHECKLIST, LOG)" },
  { icon: "⏳", text: "5 blocages critiques identifiés & documentés" }
];

let yPos = 1.2;
summaryPoints.forEach(point => {
  slide2.addText(point.icon, { x: 0.6, y: yPos, w: 0.5, h: 0.4, fontSize: 24 });
  slide2.addText(point.text, { x: 1.3, y: yPos + 0.05, w: 8, h: 0.4, fontSize: 16, fontFace: "Arial" });
  yPos += 0.6;
});

// Slide 3: DELIVERABLES
const slide3 = pres.addSlide();
slide3.background = { color: colors.white };
slide3.addShape(pres.shapes.RECTANGLE, {
  x: 0, y: 0, w: 10, h: 0.8,
  fill: { color: colors.secondary }
});
slide3.addText("Livrables de Session 9", {
  x: 0.5, y: 0.15, w: 9, h: 0.5,
  fontSize: 44, bold: true, color: colors.white,
  fontFace: "Arial"
});

const deliverables = [
  { name: "PROJECT.md", desc: "Source unique de vérité • Architecture • 9 workflows • Credentials • Security" },
  { name: "MASTER-CHECKLIST.md", desc: "Roadmap 7 phases • 25-35h déploiement • Tâches atomiques • Critères de succès" },
  { name: "CONSOLIDATION-SUMMARY.md", desc: "Index documentaire • Archive documents obsolètes • Structure clarifiée" },
  { name: "SESSION-LOG.md", desc: "Piste d'audit • Historique S1-S9 • Décisions techniques • Blockers résolus" }
];

yPos = 1.2;
deliverables.forEach(d => {
  slide3.addText(d.name, {
    x: 0.6, y: yPos, w: 3, h: 0.4,
    fontSize: 16, bold: true, color: colors.secondary, fontFace: "Arial"
  });
  slide3.addText(d.desc, {
    x: 3.8, y: yPos, w: 5.5, h: 0.4,
    fontSize: 13, color: colors.dark, fontFace: "Arial"
  });
  yPos += 0.7;
});

// Slide 4: ARCHITECTURE
const slide4 = pres.addSlide();
slide4.background = { color: colors.white };
slide4.addShape(pres.shapes.RECTANGLE, {
  x: 0, y: 0, w: 10, h: 0.8,
  fill: { color: colors.primary }
});
slide4.addText("Architecture Actuelle (01/04/2026)", {
  x: 0.5, y: 0.15, w: 9, h: 0.5,
  fontSize: 44, bold: true, color: colors.white,
  fontFace: "Arial"
});

const archRows = [
  { component: "Domaine", status: "✅ Acheté", detail: "nexusconformite.fr (~5€/an)" },
  { component: "Infrastructure", status: "✅ Confirmée", detail: "Hostinger VPS Ubuntu 22.04" },
  { component: "Workflows N8N", status: "✅ Vérifiés", detail: "9/9 présents, aucun doublon" },
  { component: "Credentials", status: "🟡 Partiels", detail: "5/8 config, 3 en attente" },
  { component: "Documentation", status: "✅ Consolidée", detail: "Single source of truth" }
];

let tableY = 1.1;
archRows.forEach(row => {
  // Component name
  slide4.addText(row.component, {
    x: 0.6, y: tableY, w: 2.2, h: 0.35,
    fontSize: 13, bold: true, color: colors.dark, fontFace: "Arial"
  });
  // Status
  slide4.addText(row.status, {
    x: 2.9, y: tableY, w: 2, h: 0.35,
    fontSize: 13, color: colors.secondary, fontFace: "Arial"
  });
  // Detail
  slide4.addText(row.detail, {
    x: 5, y: tableY, w: 4.5, h: 0.35,
    fontSize: 13, color: colors.dark, fontFace: "Arial"
  });
  tableY += 0.5;
});

// Slide 5: 7 PHASES ROADMAP
const slide5 = pres.addSlide();
slide5.background = { color: colors.white };
slide5.addShape(pres.shapes.RECTANGLE, {
  x: 0, y: 0, w: 10, h: 0.8,
  fill: { color: colors.secondary }
});
slide5.addText("Roadmap Exécution: 7 Phases", {
  x: 0.5, y: 0.15, w: 9, h: 0.5,
  fontSize: 44, bold: true, color: colors.white,
  fontFace: "Arial"
});

const phases = [
  { num: "0", name: "Blocages Critiques", time: "1-2h" },
  { num: "1", name: "Infrastructure Hostinger", time: "2-3h" },
  { num: "2", name: "Déploiement N8N", time: "3-4h" },
  { num: "3", name: "Tests des Workflows", time: "3-4h" },
  { num: "4", name: "Activation Revenus", time: "2-3h" },
  { num: "5", name: "Contenu & SEO", time: "3-5h" },
  { num: "6+7", name: "QA & Lancement", time: "Continu" }
];

let phaseY = 1.1;
phases.forEach(p => {
  // Phase number (colored circle)
  slide5.addShape(pres.shapes.OVAL, {
    x: 0.6, y: phaseY - 0.05, w: 0.35, h: 0.35,
    fill: { color: colors.accent }
  });
  slide5.addText(p.num, {
    x: 0.6, y: phaseY - 0.05, w: 0.35, h: 0.35,
    fontSize: 14, bold: true, color: colors.dark, align: "center", valign: "middle"
  });

  // Phase name
  slide5.addText(p.name, {
    x: 1.1, y: phaseY, w: 7, h: 0.25,
    fontSize: 14, bold: true, color: colors.dark, fontFace: "Arial"
  });

  // Time estimate (right aligned)
  slide5.addText(p.time, {
    x: 8.2, y: phaseY, w: 1.3, h: 0.25,
    fontSize: 12, color: colors.secondary, align: "right", fontFace: "Arial"
  });

  phaseY += 0.48;
});

slide5.addText("TOTAL: 25-35 heures jusqu'à lancement", {
  x: 0.6, y: 4.8, w: 8.8, h: 0.4,
  fontSize: 14, bold: true, color: colors.primary, italic: true, fontFace: "Arial"
});

// Slide 6: CRITICAL BLOCKERS
const slide6 = pres.addSlide();
slide6.background = { color: colors.white };
slide6.addShape(pres.shapes.RECTANGLE, {
  x: 0, y: 0, w: 10, h: 0.8,
  fill: { color: colors.primary }
});
slide6.addText("🔴 Blocages Critiques (Phase 0)", {
  x: 0.5, y: 0.15, w: 9, h: 0.5,
  fontSize: 44, bold: true, color: colors.white,
  fontFace: "Arial"
});

const blockers = [
  { name: "Brevo SMTP", issue: "535 Auth Failed", time: "15min", affects: "WF-05,06,07,09" },
  { name: "Stripe Secret", issue: "Webhook secret manquant", time: "10min", affects: "WF-04,05" },
  { name: "Gumroad Secret", issue: "Webhook secret manquant", time: "10min", affects: "WF-07" },
  { name: "Docs Légales", issue: "Placeholders à remplir", time: "30min", affects: "Launch" },
  { name: "N8N API Key", issue: "Expire 28/04/2026", time: "10min", affects: "WF-01" }
];

let blockerY = 1.1;
blockers.forEach(b => {
  slide6.addText(b.name, {
    x: 0.6, y: blockerY, w: 1.6, h: 0.3,
    fontSize: 12, bold: true, color: colors.secondary, fontFace: "Arial"
  });
  slide6.addText(b.issue, {
    x: 2.3, y: blockerY, w: 3.5, h: 0.3,
    fontSize: 11, color: colors.dark, fontFace: "Arial"
  });
  slide6.addText(b.time, {
    x: 5.9, y: blockerY, w: 1.5, h: 0.3,
    fontSize: 11, color: colors.dark, fontFace: "Arial"
  });
  slide6.addText(b.affects, {
    x: 7.5, y: blockerY, w: 2, h: 0.3,
    fontSize: 10, color: colors.secondary, fontFace: "Arial"
  });
  blockerY += 0.6;
});

slide6.addText("✅ Tous résolubles en 1-2 heures", {
  x: 0.6, y: 4.8, w: 8.8, h: 0.4,
  fontSize: 14, bold: true, color: "008000", fontFace: "Arial"
});

// Slide 7: SCALABILITY & NEXT STEPS
const slide7 = pres.addSlide();
slide7.background = { color: colors.white };
slide7.addShape(pres.shapes.RECTANGLE, {
  x: 0, y: 0, w: 10, h: 0.8,
  fill: { color: colors.secondary }
});
slide7.addText("Scalabilité & Prochaines Étapes", {
  x: 0.5, y: 0.15, w: 9, h: 0.5,
  fontSize: 44, bold: true, color: colors.white,
  fontFace: "Arial"
});

// Left column: Short term
slide7.addText("Court Terme (M2-M3)", {
  x: 0.6, y: 1.1, w: 4, h: 0.35,
  fontSize: 16, bold: true, color: colors.primary, fontFace: "Arial"
});
const shortTermItems = [
  "Résoudre Phase 0",
  "Déploiement Hostinger (Phases 1-3)",
  "Ajouter WF-10, WF-11",
  "Implémenter CRM"
];
let shortY = 1.5;
shortTermItems.forEach(item => {
  slide7.addText("→ " + item, {
    x: 0.7, y: shortY, w: 4.3, h: 0.3,
    fontSize: 12, color: colors.dark, fontFace: "Arial"
  });
  shortY += 0.35;
});

// Right column: Medium term
slide7.addText("Moyen Terme (M6+)", {
  x: 5.4, y: 1.1, w: 4, h: 0.35,
  fontSize: 16, bold: true, color: colors.primary, fontFace: "Arial"
});
const mediumTermItems = [
  "N8N Cloud (less ops)",
  "Paiement récurrent Stripe",
  "API publique partenaires",
  "Autres régulations"
];
let mediumY = 1.5;
mediumTermItems.forEach(item => {
  slide7.addText("→ " + item, {
    x: 5.5, y: mediumY, w: 4.1, h: 0.3,
    fontSize: 12, color: colors.dark, fontFace: "Arial"
  });
  mediumY += 0.35;
});

// Metrics
slide7.addText("Coûts & Revenue", {
  x: 0.6, y: 3.4, w: 9, h: 0.3,
  fontSize: 14, bold: true, color: colors.secondary, fontFace: "Arial"
});
slide7.addText("Startup: 15€/mois | M12: 40-45€/mois | Revenue M1: 1,200-1,800€ | M12: 12,300-23,500€", {
  x: 0.6, y: 3.8, w: 9, h: 0.6,
  fontSize: 12, color: colors.dark, fontFace: "Arial"
});

// Slide 8: CONCLUSION
const slide8 = pres.addSlide();
slide8.background = { color: colors.primary };
slide8.addText("Conclusion", {
  x: 0.5, y: 1.5, w: 9, h: 0.6,
  fontSize: 48, bold: true, color: colors.accent,
  align: "center", fontFace: "Arial"
});
slide8.addText("De projet fragmenté à structure exécutable", {
  x: 0.5, y: 2.4, w: 9, h: 0.5,
  fontSize: 24, color: colors.white,
  align: "center", italic: true, fontFace: "Arial"
});
slide8.addText([
  { text: "✅ 9 workflows vérifiés", options: { breakLine: true } },
  { text: "✅ 3 documents maîtres consolidés", options: { breakLine: true } },
  { text: "✅ Roadmap 7 phases complète", options: { breakLine: true } },
  { text: "✅ Blocages Phase 0 documentés", options: { breakLine: true } },
  { text: "\n→ Prêt pour déploiement Hostinger" }
], {
  x: 1.5, y: 3.3, w: 7, h: 2,
  fontSize: 18, color: colors.light,
  align: "center", valign: "middle", fontFace: "Arial"
});

// Save
pres.writeFile({ fileName: "NEXUS-SESSION9-SLIDES.pptx" });
console.log("✅ Présentation créée: NEXUS-SESSION9-SLIDES.pptx");
