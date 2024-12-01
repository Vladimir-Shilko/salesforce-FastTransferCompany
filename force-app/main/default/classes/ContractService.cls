public class ContractService {
	public static void shareContractWithUser(List<Contract> newContracts){
        List<AccountShare> contractShares = new List<AccountShare>();

        for (Contract contract : newContracts) {
      
            if (contract.Shipping_CompanyUser__c != null) {
                AccountShare share = new AccountShare();
                share.AccountId = contract.AccountId;
                share.UserOrGroupId = contract.Shipping_CompanyUser__c;
                share.AccountAccessLevel = 'Edit'; 
                share.OpportunityAccessLevel = 'read';
                share.RowCause = Schema.AccountShare.RowCause.Manual; 

                contractShares.add(share);
            }
        }

        if (!contractShares.isEmpty()) {
            try{
                insert contractShares; 
            }
            catch(Exception e){
                return;
            }
            
        }
    }
}