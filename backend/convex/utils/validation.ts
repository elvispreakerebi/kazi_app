export class ValidationError extends Error {
  constructor(message: string) {
    super(message);
    this.name = "ValidationError";
  }
}

export function validateEmail(email: string): void {
  // RFC-5322-like email regex (simplified)
  const emailPattern = /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/;
  if (!emailPattern.test(email)) {
    throw new ValidationError("Invalid email address.");
  }
}

export function validatePassword(password: string): void {
  if (typeof password !== "string" || password.length < 8) {
    throw new ValidationError("Password must be at least 8 characters.");
  }
  if (!/[A-Z]/.test(password)) {
    throw new ValidationError("Password must contain at least one uppercase letter.");
  }
  if (!/[a-z]/.test(password)) {
    throw new ValidationError("Password must contain at least one lowercase letter.");
  }
  if (!/[0-9]/.test(password)) {
    throw new ValidationError("Password must contain at least one digit.");
  }
}
