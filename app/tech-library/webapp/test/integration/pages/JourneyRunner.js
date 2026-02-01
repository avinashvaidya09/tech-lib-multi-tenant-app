sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"ns/techlibrary/test/integration/pages/BooksList",
	"ns/techlibrary/test/integration/pages/BooksObjectPage",
	"ns/techlibrary/test/integration/pages/BookAuthorsObjectPage"
], function (JourneyRunner, BooksList, BooksObjectPage, BookAuthorsObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('ns/techlibrary') + '/test/flp.html#app-preview',
        pages: {
			onTheBooksList: BooksList,
			onTheBooksObjectPage: BooksObjectPage,
			onTheBookAuthorsObjectPage: BookAuthorsObjectPage
        },
        async: true
    });

    return runner;
});

