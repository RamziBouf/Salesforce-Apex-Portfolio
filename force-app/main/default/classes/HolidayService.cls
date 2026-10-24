public with sharing class HolidayService {
    public static final sTRING END_POINT =  'callout:Nager_Date/api/v3/PublicHolidays/';
    public static void syncHolidays(String coutryCode, Integer year){
        if (String.isBlank(coutryCode) || year == null){
            System.debug(LoggingLevel.ERROR, 'Country code and year are required!');
            return;
        }

        String coutry = coutryCode.trim().toUpperCase();

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
    }

}