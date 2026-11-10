/// Permission strings (`<resource>:<action>`) the app gates UI on.
/// Add new ones here instead of scattering literals in widgets.
class Permissions {
  const Permissions._();

  static const invoiceCreate = 'invoice:create';
  static const invoiceRead = 'invoice:read';
  static const invoiceUpdate = 'invoice:update';
  static const invoiceDelete = 'invoice:delete';
  static const inspectionCreate = 'inspection:create';
  static const inspectionUpdate = 'inspection:update';
  static const pdfGenerate = 'pdf:generate';
  static const usersRead = 'users:read';
  static const rolesRead = 'roles:read';
  static const branchesRead = 'branches:read';
}
