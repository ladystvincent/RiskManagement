using RiskService from './risk-service';

annotate RiskService.Risks with {
    ID          @title: 'Risk';
	title       @title: 'Title';
    owner       @title: 'Owner';
	prio        @title: 'Priority';
	descr       @title: 'Description';
	miti        @title: 'Mitigation';
	impact      @title: 'Impact';
    bp          @(
        title: 'Business Partner',
        Common.Text: bp.fullName,
        Common.TextArrangement: #TextOnly
        );
}

annotate RiskService.Mitigations with {
	ID @(
		UI.Hidden,
		Common: {
		Text: descr
		}
	);
	description  @title: 'Description';
	owner        @title: 'Owner';
	timeline     @title: 'Timeline';
	risks        @title: 'Risks';
}

annotate RiskService.Risks with @(
	UI: {
		HeaderInfo: {
			TypeName: 'Risk',
			TypeNamePlural: 'Risks',
			Title          : {
                $Type : 'UI.DataField',
                Value : title
            },
			Description : {
				$Type: 'UI.DataField',
				Value: descr
			}
		},
		SelectionFields: [prio, owner],
		LineItem: [
			{Value: title},
			{
                Value: miti_ID,
                ![@HTML5.CssDefaults] : {width : '100%'}
            },
            {Value: owner},
			{
				Value: prio,
				Criticality: criticality
			},
			{
				Value: impact,
				Criticality: criticality
			}
		],
		Facets: [
			{$Type: 'UI.ReferenceFacet', Label: 'Main', Target: '@UI.FieldGroup#Main'}
		],
		FieldGroup#Main: {
			Data: [
				{Value: miti_ID},
				{
					Value: prio,
					Criticality: criticality
				},
				{
					Value: impact,
					Criticality: criticality
				},
                {Value: owner},
                {Value: bp_ID},
                {Value: bp.isBlocked}
			]
		}
	},
);

annotate RiskService.Risks with {
	miti @(
		Common: {
			//show text, not id for mitigation in the context of risks
			Text: miti.descr  , TextArrangement: #TextOnly,
			ValueList: {
				Label: 'Mitigations',
				CollectionPath: 'Mitigations',
				Parameters: [
					{ $Type: 'Common.ValueListParameterInOut',
						LocalDataProperty: miti_ID,
						ValueListProperty: 'ID'
					},
					{ $Type: 'Common.ValueListParameterDisplayOnly',
						ValueListProperty: 'descr'
					}
				]
			}
		}
	);
}

annotate RiskService.BusinessPartners with {
    ID          @(
        title: 'ID',
        Common.Text: fullName
    );
    fullName    @title: 'Name';
    isBlocked @title : 'Business Partner Blocked';
};

// Annotations for value help

annotate RiskService.Risks with {
    bp @(
        Common.ValueList: {
            Label: 'BusinessPartner',
            CollectionPath: 'BusinessPartners',
            Parameters: [
                { $Type: 'Common.ValueListParameterInOut',
                    LocalDataProperty: bp_ID,
                    ValueListProperty: 'ID'
                },
                { $Type: 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'fullName'
                }
            ]
        }
    );
}

annotate RiskService.BusinessPartners with @Capabilities.SearchRestrictions.Searchable : false;