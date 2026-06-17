# Website Testing Checklist

## Quick Reference for All Test Categories

### 1. Functionality Testing Checklist
- [ ] Homepage loads without errors
- [ ] All buttons are clickable and functional
- [ ] Forms accept input and submit correctly
- [ ] Links work (internal and external)
- [ ] Navigation menus function properly
- [ ] Search functionality works (if present)
- [ ] Video/media players work (if present)
- [ ] Download links work
- [ ] Error messages are clear and helpful
- [ ] No console errors on main pages

### 2. Security Testing Checklist
- [ ] HTTPS is enabled (green padlock)
- [ ] No mixed content (HTTP resources on HTTPS page)
- [ ] Security headers present:
  - [ ] Content-Security-Policy
  - [ ] X-Frame-Options
  - [ ] X-Content-Type-Options
  - [ ] Strict-Transport-Security
- [ ] No sensitive data in URLs
- [ ] No API keys exposed in code
- [ ] Forms are CSRF protected
- [ ] Authentication uses secure methods
- [ ] Passwords not exposed in DevTools
- [ ] No outdated libraries visible

### 3. Performance Testing Checklist
- [ ] Page load time < 3 seconds
- [ ] Largest Contentful Paint < 2.5s
- [ ] First Input Delay < 100ms
- [ ] Cumulative Layout Shift < 0.1
- [ ] Images are optimized (check Network tab)
- [ ] JavaScript is minified
- [ ] CSS is minified
- [ ] Unused CSS is removed
- [ ] Render-blocking resources are minimized
- [ ] Total page size is reasonable (< 5MB)

### 4. Accessibility Testing Checklist
- [ ] All images have alt text
- [ ] Headings are hierarchical (h1, h2, h3...)
- [ ] Links have descriptive text (not "click here")
- [ ] Color contrast >= 4.5:1 for text
- [ ] Forms have associated labels
- [ ] Keyboard navigation works (Tab key)
- [ ] Focus indicators are visible
- [ ] No keyboard traps
- [ ] Videos have captions (if present)
- [ ] Screen reader friendly (check semantic HTML)

### 5. Mobile Responsiveness Checklist
- [ ] Layout works at 375px width
- [ ] Layout works at 768px width
- [ ] Layout works at 1024px width
- [ ] Touch targets >= 48x48 pixels
- [ ] No horizontal scrolling
- [ ] Text is readable without zooming
- [ ] Buttons are finger-friendly
- [ ] Images scale properly
- [ ] Mobile menu is accessible
- [ ] Forms are easy to fill on mobile

### 6. Cross-Browser Compatibility Checklist
- [ ] Works in Chrome/Chromium
- [ ] Works in Firefox (test via description)
- [ ] Works in Safari (test via description)
- [ ] No vendor prefix issues
- [ ] Flexbox/Grid layouts work
- [ ] CSS animations work
- [ ] JavaScript runs without errors
- [ ] No unusual font rendering issues

### 7. SEO Basics Checklist
- [ ] Page title is present and unique
- [ ] Meta description is present and relevant
- [ ] H1 tag is present and unique
- [ ] Content is well-structured with headers
- [ ] Internal links use descriptive anchor text
- [ ] Mobile-friendly (viewport meta tag present)
- [ ] robots.txt is present
- [ ] sitemap.xml is present
- [ ] Structured data (schema.org) is used
- [ ] URLs are descriptive and clean

---

## Common Issues to Look For

### Functionality
- Broken links (404 errors)
- Forms that don't submit
- Missing pages in menu
- Outdated or placeholder content
- Missing functionality

### Security
- Sites without HTTPS
- Hardcoded API keys in frontend
- Exposed authentication tokens
- No CSRF protection
- Vulnerable dependencies

### Performance
- Large unoptimized images
- Huge JavaScript bundles
- Render-blocking resources
- No caching headers
- Synchronous scripts

### Accessibility
- Missing alt text
- Poor color contrast
- Not keyboard accessible
- Unlabeled form inputs
- Wrong heading order

### Mobile
- Text too small to read
- Buttons too small
- Overflowing content
- Broken layout
- Difficult navigation

---

## Tools You Can Use (in browser DevTools)

### Chrome DevTools Features
- **Lighthouse**: Run audit for performance, accessibility, SEO
- **Network tab**: Check load times, file sizes, types
- **Console**: Check for JavaScript errors
- **Elements**: Inspect HTML structure, check semantics
- **Application**: Check cookies, local storage, security
- **Performance**: Record and analyze performance

### Accessibility Tools
- **Lighthouse Accessibility Audit**
- Manual keyboard navigation (Tab key)
- Check color contrast manually

### Performance Tools
- **Lighthouse Performance Audit**
- **Network tab waterfall**
- **Coverage tab**: Find unused CSS/JS

---

## Report Findings Template

### For Each Finding, Include:
1. **What**: What is the issue?
2. **Where**: Which page/element?
3. **Why**: Why is it a problem?
4. **How**: How to fix it?
5. **Severity**: Critical, High, Medium, Low

### Example:
```
Issue: Missing alt text on product images
Location: Homepage, product grid section
Why: Screen reader users can't understand images; impacts accessibility score
How: Add descriptive alt text to all product images
Severity: High
```
