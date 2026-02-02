using tech_lib_multi_tenant_app_srv as service from '../../srv/service';
annotate service.Books with @(
    UI.FieldGroup #GeneratedGroup : {
        $Type : 'UI.FieldGroupType',
        Data : [
            {
                $Type : 'UI.DataField',
                Label : '{i18n>Title1}',
                Value : title,
            },
            {
                $Type : 'UI.DataField',
                Label : '{i18n>Isbn1}',
                Value : isbn,
            },
            {
                $Type : 'UI.DataField',
                Label : '{i18n>Publicationdate1}',
                Value : publicationDate,
            },
            {
                $Type : 'UI.DataField',
                Label : '{i18n>Genre1}',
                Value : genre,
            },
            {
                $Type : 'UI.DataField',
                Value : bookAuthors.author.name,
                Label : '{i18n>Name1}',
            },
            {
                $Type : 'UI.DataField',
                Value : bookAuthors.author.bio,
                Label : '{i18n>Bio}',
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
            Label : '{i18n>Title}',
            Value : title,
        },
        {
            $Type : 'UI.DataField',
            Label : '{i18n>Isbn}',
            Value : isbn,
        },
        {
            $Type : 'UI.DataField',
            Label : '{i18n>Publicationdate}',
            Value : publicationDate,
        },
        {
            $Type : 'UI.DataField',
            Label : '{i18n>Genre}',
            Value : genre,
        },
    ],
);

