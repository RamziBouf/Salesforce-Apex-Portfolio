public with sharing class HolidayService {
    public static final sTRING END_POINT =  'callout:Nager_Date/api/v3/PublicHolidays/';
    public static void syncHolidays(String coutryCode, Integer year){
        if (String.isBlank(coutryCode) || year == null){
            System.debug(LoggingLevel.ERROR, 'Country code and year are required!');
            return;
        }

        String country = coutryCode.trim().toUpperCase();

        HttpRequest req = new HttpRequest();
        req.setEndpoint(END_POINT);
        req.setMethod('GET');
        req.setTimeout(20000);

        HttpResponse res;

        try{
            res = new Http().send(req);
        }catch (CalloutException e){
            System.debug(LoggingLevel.ERROR, 'Callout failed: ' + e.getMessage());
            return;
        }

        if(res.getStatusCode() != 200){
            System.debug(LoggingLevel.ERROR, 'Holiday API returned ' + res.getStatusCode() + ' ' + res.getStatus());
            return;
        }
        List<Object> entries = (List<Object>) JSON.deserializeUntyped(res.getBody());

        Map<String, Public_Holiday__c> holidaysByKey = new Map<String, Public_Holiday__c>();
        for(Object item : entries){
            Map<String, Object> entry = (Map<String, Object>) item;

            String dateText = (String) entry.get('date');
            String name = (String) entry.get('name');
            String localName = (String) entry.get('localName');
            Boolean isGlobal = (Boolean) entry.get('global');
            String countryCode = (String) entry.get('countryCode');
            List<Object> types = (List<Object>) entry.get('types');
            String holidayType = (types != null && !types.isEmpty())
                ? String.valueOf(types[0]) : null;

            List<Object> counties = (List<Object>) entry.get('counties');
            String countiesText = (counties != null && !counties.isEmpty())
                ? String.join(counties, ', ') : null;
            String key = country + '-' + dateText + '-' + name;

            holidaysByKey.put(key, new Public_Holiday__c(
                Name = name.abbreviate(80),
                Holiday_Date__c = Date.valueOf(dateText),
                Local_Name__c = localName,
                Country_Code__c = countryCode,
                Is_Global__c = isGlobal,
                Holiday_Type__c = holidayType,
                Counties__c = countiesText,
                Holiday_Key__c = key
            ));
        }

        List<Database.UpsertResult> results = Database.upsert(holidaysByKey.values(), Public_Holiday__c.Holiday_Key__c, false);
          Integer created = 0;
        Integer updated = 0;
        Integer failed = 0;
        for (Integer i = 0; i < results.size(); i++) {
            if (results[i].isSuccess()) {
                if (results[i].isCreated()) {
                    created++;
                } else {
                    updated++;
                }
            } else {
                failed++;
                System.debug(LoggingLevel.ERROR, 'Upsert failed: '
                    + results[i].getErrors()[0].getMessage());
            }
        }
         System.debug('Holiday sync ' + country + ' ' + year
            + ' -> created: ' + created + ', updated: ' + updated + ', failed: ' + failed);
    }

}