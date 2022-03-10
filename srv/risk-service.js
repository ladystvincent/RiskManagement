const cds = require('@sap/cds')
/**
 * Implementation for Risk Management service defined in ./risk-service.cds
 */
module.exports = cds.service.impl(async function() {
    this.after('READ', 'Risks', risksData => {
        const risks = Array.isArray(risksData) ? risksData : [risksData];
        risks.forEach(risk => {
            if (risk.impact >= 25000) {
                risk.criticality = 1;
            } else {
                if (risk.impact >= 10000) {
                    risk.criticality = 2;
                } else {
                    risk.criticality = 3;
                }
            }
        });
    });

    const BPsrv = await cds.connect.to("API_BUSINESS_PARTNER");

    this.on("READ", 'BusinessPartners', async (req) => {
        req.query.where("BusinessPartnerFullName <> ''");

        return await BPsrv.transaction(req).send({
            query: req.query,
            headers: {
                apikey: process.env.apikey,
            },
        });
    });

    // Risks?$expand=bp
    this.on("READ", 'Risks', async (req, next) => {
        if (!req.query.SELECT.columns) return next();
        const expandIndex = req.query.SELECT.columns.findIndex(
            ({ expand, ref }) => expand && ref[0] === "bp"
        );
        if (expandIndex < 0) return next();

        // Remove expand from query
        req.query.SELECT.columns.splice(expandIndex, 1);

        // Make sure bp_ID will be returned
        if (!req.query.SELECT.columns.indexOf('*') >= 0 &&
            !req.query.SELECT.columns.find(
                column => column.ref && column.ref.find((ref) => ref == "bp_ID"))
        ) {
            req.query.SELECT.columns.push({ ref: ["bp_ID"] });
        }

        const risks = await next();

        const asArray = x => Array.isArray(x) ? x : [ x ];

        // Request all associated bps
        const bpIds = asArray(risks).map(risk => risk.bp_ID);
        //const bps = await BPsrv.run(SELECT.from('RiskService.BusinessPartners').where({ ID: bpIds }));
        const bps = await BPsrv.send({
            query: SELECT.from('RiskService.BusinessPartners').where({ ID: bpIds }),
            headers: {
                apikey: process.env.apikey,
            },
        });


        // Convert in a map for easier lookup
        const bpsMap = {};
        for (const bp of bps)
            bpsMap[bp.ID] = bp;

        // Add bp to result
        for (const note of asArray(risks)) {
            note.bp = bpsMap[note.bp_ID];
        }

        return risks;
    });
});

