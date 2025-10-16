import { Resend } from 'resend';

const resend = new Resend(process.env.RESEND_API_KEY || '');
const EMAIL_FROM = process.env.EMAIL_FROM || 'onboarding@resend.dev';

/**
 * Send an email using Resend
 * @param params Object
 * @param params.to - Recipient email address
 * @param params.subject - Email subject
 * @param params.html - HTML content (optional)
 * @param params.text - Plain text content (optional)
 */
export async function sendEmail({ to, subject, html, text }: { to: string; subject: string; html?: string; text?: string }) {
  const emailOptions: any = {
    from: EMAIL_FROM,
    to: [to],
    subject,
  };
  if (html) emailOptions.html = html;
  if (text) emailOptions.text = text;

  const { error } = await resend.emails.send(emailOptions);
  if (error) {
    // Optionally log
    // console.error('Resend email error:', error);
    throw new Error('Failed to send email: ' + (typeof error === 'object' ? JSON.stringify(error) : error));
  }
}
