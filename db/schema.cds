namespace tech_lib_multi_tenant_app;
using { cuid } from '@sap/cds/common';

@assert.unique: { title: [title] }
entity Books : cuid {
  title: String(100) @mandatory;
  isbn: String(20);
  publicationDate: Date;
  genre: String(50);
  author: Association to Authors;
}

@assert.unique: { name: [name] }
entity Authors : cuid {
  name: String(100) @mandatory;
  bio: String(500);
  birthDate: Date;
  books: Association to many Books on books.author = $self;
}

