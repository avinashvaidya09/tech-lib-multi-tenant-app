sap.ui.define(['sap/fe/test/ObjectPage'], function(ObjectPage) {
    'use strict';

    var CustomPageDefinitions = {
        actions: {},
        assertions: {}
    };

    return new ObjectPage(
        {
            appId: 'ns.techlibrary',
            componentId: 'BookAuthorsObjectPage',
            contextPath: '/Books/bookAuthors'
        },
        CustomPageDefinitions
    );
});