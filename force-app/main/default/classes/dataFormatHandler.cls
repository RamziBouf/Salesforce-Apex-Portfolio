public with sharing class dataFormatHandler {
    public static void changeDataFormat(List<Contact> newContacts){
        for(Contact con : newContacts){
            con.FirstName = formatName(con.FirstName);
            con.LastName = formatName(con.LastName);
            con.Phone = formatPhone(con.Phone);
            con.HomePhone = formatPhone(con.HomePhone);
            con.MobilePhone = formatPhone(con.MobilePhone);
            con.OtherPhone = formatPhone(con.OtherPhone);
            con.AssistantPhone = formatPhone(con.AssistantPhone);
        }}

        private static String formatName(String name){
            if(String.isBlank(name)){
                return name;
            }
            return name.trim().toLowerCase().capitalize();
        }
        private static String formatPhone(String phone){
            if(String.isBlank(phone)){
                return phone;
            }
            return phone.replaceAll('[^0-9]', '');
        }
    }
