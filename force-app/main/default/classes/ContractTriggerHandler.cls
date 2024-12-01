public class ContractTriggerHandler extends TriggerHandler{
    protected override void afterInsert() {
    	ContractService.shareContractWithUser(Trigger.New);
    }
}