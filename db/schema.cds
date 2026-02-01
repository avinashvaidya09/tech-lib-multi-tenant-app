namespace tech_lib_multi_tenant_app;
using { cuid } from '@sap/cds/common';

@assert.unique: { title: [title] }
entity Books : cuid {
  title: String(100) @mandatory;
  isbn: String(20);
  publicationDate: Date;
  genre: String(50);
  bookAuthors: Association to many BookAuthors on bookAuthors.book = $self;
}

@assert.unique: { name: [name] }
entity Authors : cuid {
  name: String(100) @mandatory;
  bio: String(500);
  birthDate: Date;
  bookAuthors: Association to many BookAuthors on bookAuthors.author = $self;
}

entity BookAuthors : cuid {
  book  : Association to Books;
  author: Association to Authors;
}
