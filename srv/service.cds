using { tech_lib_multi_tenant_app as my } from '../db/schema.cds';

@path: '/service/tech_lib_multi_tenant_app'
@requires: 'authenticated-user'
service tech_lib_multi_tenant_appSrv {
  @odata.draft.enabled
  entity Books as projection on my.Books;
  @odata.draft.enabled
  entity Authors as projection on my.Authors;
}