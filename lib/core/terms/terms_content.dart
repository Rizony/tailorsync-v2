/// The canonical text of TailorSync's Terms of Service and Privacy Policy.
/// Bump [kTermsVersion] whenever the content changes — this forces all users
/// to re-accept even if they previously accepted an older version.
library;

const int kTermsVersion = 1;

const String kTermsOfService = '''
Terms of Service for TailorSync
Last Updated: Feb 22, 2026

1. Acceptance of Terms
By accessing or using the TailorSync mobile application, you agree to be bound by these Terms of Service. If you disagree with any part of the terms, you may not access the service.

2. Description of Service
TailorSync is a business management tool designed for tailors and fashion designers to manage customer measurements, track orders, generate invoices, and monitor business analytics.

3. User Accounts & Responsibilities
• You are responsible for safeguarding the password and OTPs that you use to access the Service.
• You agree not to disclose your password to any third party.
• You are solely responsible for the data you enter into the app, including ensuring you have the right to store your clients' personal data (measurements, photos, contact info).

4. Subscriptions and Payments
TailorSync may offer both Free (Freemium) and Premium subscription tiers.
• Premium features are billed on a recurring basis as outlined in the app.
• We reserve the right to change our subscription prices with reasonable prior notice.

5. User-Generated Content
You retain all your ownership rights to the customer data, measurements, and images you upload to TailorSync. By uploading content, you grant us a license to host, store, and display that data solely for the purpose of providing the TailorSync service to you.

6. Acceptable Use
You agree not to use TailorSync to:
• Store illegal, offensive, or highly sensitive confidential data (e.g., government IDs, medical records).
• Reverse engineer, decompile, or copy the application's source code.

7. Limitation of Liability
TailorSync is provided on an "AS IS" and "AS AVAILABLE" basis. We shall not be liable for any indirect, incidental, or consequential damages, including but not limited to loss of data, loss of revenue, or business interruption resulting from the use or inability to use the app.

8. Termination
We may terminate or suspend your account immediately, without prior notice or liability, for any reason whatsoever, including without limitation if you breach the Terms.

9. Contact Us
For any questions regarding these Terms, please contact us at: tailorsync@gmail.com
''';

const String kPrivacyPolicy = '''
Privacy Policy for TailorSync
Last Updated: Mar 22, 2026

1. Introduction
Welcome to TailorSync ("we," "our," or "us"). We are committed to protecting your personal information and your right to privacy. This Privacy Policy governs the data collection and usage of the TailorSync mobile application and related services.

2. Information We Collect
We collect personal information that you voluntarily provide to us when you register on the App.
• Account Information: Name, email address, phone number, and shop details.
• Client Data: As a tailor using our service, you may input data regarding your own customers, including their names, phone numbers, body measurements, and design images/sketches.
• Device Data: We may collect device information (such as operating system version) to help us troubleshoot crashes and improve app performance.

3. How We Use Your Information
We use the information we collect or receive to:
• Facilitate account creation and logon processes (via Supabase).
• Provide, operate, and maintain the TailorSync app.
• Sync your data across your devices securely.
• Send you administrative information, such as changes to our terms or invoice generations.

4. Third-Party Services
We use third-party services to power our application, specifically Supabase for secure cloud database hosting, image storage, and user authentication. Your data is stored securely on their servers. We do not sell, rent, or trade your personal information or your clients' information to third parties for marketing purposes.

5. Data Retention and Account Deletion
We keep your information for as long as your account is active. You have the right to request the deletion of your account and all associated data (including client measurements and images) at any time by contacting us or using the in-app deletion feature.

6. Contact Us
If you have questions or comments about this notice, you may email us at: tailorsync@gmail.com
''';
