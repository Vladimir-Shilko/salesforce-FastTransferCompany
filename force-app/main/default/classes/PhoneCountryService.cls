public with sharing class PhoneCountryService {
     public static void updateCountryFromPhone(List<SObject> records, Schema.SObjectField countryCodeField, Schema.SObjectField updateField) {
        
        if (records == null || records.isEmpty() || countryCodeField == null || updateField == null) return;
        
        List<String> serializedRecords = new List<String>();

        SObjectType sObjectType = records[0].getSObjectType();

        for (SObject record : records) {
            String phoneField = (String) record.get(countryCodeField);
            if (String.isBlank(phoneField)) continue;  
            serializedRecords.add(JSON.serialize(record));
        }

       	
        updateCountryFromPhoneApiAsync(sObjectType.toString(), serializedRecords, countryCodeField.toString(), updateField.toString());
    }
    
    @future(callout=true)
	 private static void updateCountryFromPhoneApiAsync(String objectType, List<String> serializedRecords, String countryCodeFieldName, String updateFieldName) {
        Type t = Type.forName('Schema.'+objectType);
        if(t == null) return;
        List<sObject> recordsToUpdate = new List<sObject>();
         
		SObjectType currentType = Schema.getGlobalDescribe().get(objectType);
    	if(currentType == null) return;
        
        Map<String, Schema.SObjectField> fields = currentType.getDescribe().fields.getMap(); 

    	SObjectField countryCodeField = fields.get(countryCodeFieldName);
        if(countryCodeField == null) return;
        
        SObjectField updateField = fields.get(updateFieldName);
        if(updateField == null) return;
         
        for (String serializedRecord : serializedRecords) {
            sObject record = (sObject)JSON.deserialize(serializedRecord, t);
           	if(record == null) continue;
            
            recordsToUpdate.add(record);
    	}
       
        updateCountryByPhoneFromAPI(recordsToUpdate, countryCodeField, updateField);
    }

    private static void updateCountryByPhoneFromAPI(List<sObject> records, Schema.SObjectField countryCodeField, Schema.SObjectField updateField) {	
        if(records ==null || countryCodeField == null || updateField == null) return;

        for (sObject record : records) {
            
            String phoneField = (String) record.get(countryCodeField);
            if (String.isBlank(phoneField)) continue;
            
            String countryCode = extractCountryCode(phoneField);
            if (String.isBlank(countryCode) )continue;
            
            String countryName = getCountryFromApiByCode(countryCode);
            record.put(updateField, countryName);    
        }
        
        try {
            update records;
        } catch (DmlException e) {
            System.debug('Error updating records: ' + e.getMessage());
        }
   
    }
     
    private static String extractCountryCode(String phone) {
        Pattern pattern = Pattern.compile('\\+(\\d{1,3})');
        Matcher matcher = pattern.matcher(phone);
        if (!matcher.find()) {
            return null;
        }
        return matcher.group(1);
    }

    private static String getCountryFromApiByCode(String countryCode) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://restcountries.com/v2/callingcode/' + countryCode);
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');

        HttpResponse response = http.send(request);
        	
        List<Object> countries = (List<Object>) JSON.deserializeUntyped(response.getBody());
        if (countries.isEmpty()) return null;
        
        Map<String, Object> countryData = (Map<String, Object>) countries[0];
        return (String) countryData.get('name');
    }
}