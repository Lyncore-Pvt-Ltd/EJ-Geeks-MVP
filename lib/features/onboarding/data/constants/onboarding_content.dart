import '../../domain/entities/intro_slide.dart';

const List<IntroSlide> kIntroSlides = [
  IntroSlide(
    headline:
        'Drive Your Workshop’s Efficiency and Profitability with AutoFlow',
    body:
        'The cloud-native mobile inspection, invoicing, and multi-branch '
        'management platform built specifically for modern auto repair shops, '
        'mechanics, and workshop managers.',
    illustration: IntroIllustration.highlights,
  ),
  IntroSlide(
    headline:
        'Eliminate Paperwork and Upgrade to Mobile-First Digital Vehicle '
        'Inspections',
    body:
        'AutoFlow empowers technicians in the bay to perform comprehensive, '
        'standardized vehicle assessments in minutes directly from a mobile '
        'phone or tablet.',
    illustration: IntroIllustration.inspection,
  ),
  IntroSlide(
    headline: 'Show, Don’t Just Tell — High-Resolution Inspection Photos',
    body:
        'Customers trust what they can see. AutoFlow makes it seamless for '
        'mechanics to upload visual evidence directly from the workshop bay.',
    illustration: IntroIllustration.photos,
  ),
];

/// (title, tag) for each slide-1 highlight tile.
const List<(String, String)> kIntroHighlights = [
  ('Digital Inspection Checklists', 'Single-tap grading'),
  ('Photo Defect Evidence', 'HD inspection photos'),
  ('Multi-Branch Operations', 'Scoped RBAC'),
  ('Instant Accounting & Invoicing', 'GST + PDF'),
];

const List<String> kIntroSections = [
  'Engine Bay',
  'Interior',
  'Exterior',
  'Tyres',
  'Wheels & Brakes',
  'Road Test',
];

/// (item, rating) rows graded in sequence on slide 2.
const List<(String, String)> kIntroChecks = [
  ('Oil level & condition', 'Good'),
  ('Coolant hoses', 'Fair'),
  ('Drive belt', 'Repair Required'),
];

const List<String> kIntroRatingKeys = ['G', 'F', 'R', '–', '?'];

const String kIntroTechnicianNote =
    'Engine Bay note: drive belt cracked, replace before next service.';

/// (label, value) rows on the post-login summary card.
const List<(String, String)> kTodaySummary = [
  ('Inspections today', '7'),
  ('Vehicles in progress', '4'),
  ('Awaiting authorization', '2'),
];
