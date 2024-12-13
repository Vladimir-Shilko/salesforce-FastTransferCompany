public abstract without sharing class FreightRequestData {
    
    protected abstract void fill (Map<String, String> data);
    
    protected String validateString(Map<String, String> data, String key) {
        if (!data.containsKey(key) || String.isBlank(data.get(key))) {
            throw new IllegalArgumentException('Missing or invalid value for required field: ' + key);
        }
        return data.get(key);
    }

    protected Decimal validateDecimal(Map<String, String> data, String key) {
        if (!data.containsKey(key) || String.isBlank(data.get(key))) {
            throw new IllegalArgumentException('Missing or invalid value for required field: ' + key);
        }
        try {
            return Decimal.valueOf(data.get(key));
        } catch (Exception e) {
            throw new IllegalArgumentException('Invalid decimal value for field: ' + key);
        }
    }
    
    protected Date validateDate(Map<String, String> data, String key) {
    if (!data.containsKey(key) || String.isBlank(data.get(key))) {
        throw new IllegalArgumentException('Missing or invalid value for required field: ' + key);
    }

    try {
       
        Date parsedDate = Date.valueOf(data.get(key));

        if (parsedDate < Date.today()) {
            throw new IllegalArgumentException('Invalid date for field: ' + key + '. Date cannot be earlier than today.');
        }

        return parsedDate;
    } catch (Exception e) {
        throw new IllegalArgumentException('Invalid date value for field: ' + key + '. Please provide a valid date.');
    }
}

}