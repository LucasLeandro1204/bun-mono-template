export function normalizeGreetingName(name: string): string {
  const normalizedName = name.trim();

  if (normalizedName.length === 0) {
    throw new TypeError('Greeting name must contain at least one non-whitespace character.');
  }

  return normalizedName;
}

export function greet(name: string): string {
  return `Hello, ${normalizeGreetingName(name)}!`;
}
