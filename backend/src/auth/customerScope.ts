/**
 * Identity context that must be established by a verified authentication layer.
 * Do not construct this value directly from client-provided request data.
 */
export type AuthenticatedCustomer = Readonly<{
  customerId: string;
}>;

/**
 * Return the customer query scope for an authenticated identity, or null when
 * no usable identity is available. Callers must deny access when this returns
 * null; an unscoped financial-record query must not be used as a fallback.
 */
export function customerScope(
  identity: AuthenticatedCustomer | null | undefined,
): { customerId: string } | null {
  if (
    identity == null ||
    typeof identity.customerId !== 'string' ||
    identity.customerId.trim().length === 0
  ) {
    return null;
  }

  return { customerId: identity.customerId };
}
