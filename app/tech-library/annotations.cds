using tech_lib_multi_tenant_app_srv as service from '../../srv/service';
annotate service.Books with @(
    UI.FieldGroup #GeneratedGroup : {
        $Type : 'UI.FieldGroupType',
        Data : [
            {
                $Type : 'UI.DataField',
                Label : 'title',
                Value : title,
            },
            {
                $Type : 'UI.DataField',
                Label : 'isbn',
                Value : isbn,
            },
            {
                $Type : 'UI.DataField',
                Label : 'publicationDate',
                Value : publicationDate,
            },
            {
                $Type : 'UI.DataField',
                Label : 'genre',
                Value : genre,
            },
        ],
    },
    UI.Facets : [
        {
            $Type : 'UI.ReferenceFacet',
            ID : 'GeneratedFacet1',
            Label : 'General Information',
            Target : '@UI.FieldGroup#GeneratedGroup',
        },
    ],
    UI.LineItem : [
        {
            $Type : 'UI.DataField',
            Label : 'title',
            Value : title,
        },
        {
            $Type : 'UI.DataField',
            Label : 'isbn',
            Value : isbn,
        },
        {
            $Type : 'UI.DataField',
            Label : 'publicationDate',
            Value : publicationDate,
        },
        {
            $Type : 'UI.DataField',
            Label : 'genre',
            Value : genre,
        },
    ],
);

