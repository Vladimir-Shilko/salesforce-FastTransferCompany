import { LightningElement, api, wire, track } from 'lwc';
import getRelatedOffers from '@salesforce/apex/OrderController.getRelatedOffers';
import createContract from '@salesforce/apex/OrderController.createContract';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CreateContractWithOffer extends LightningElement {
    @api recordId; 
    isModalOpen = false; 
    @track offers = []; 
    selectedOfferId;

    columns = [
        { label: 'Offer Name', fieldName: 'Name' },
        { label: 'Max Price', fieldName: 'Max_Price__c', type: 'currency' },
        { label: 'Min Price', fieldName: 'Min_Price__c', type: 'currency' },
        { label: 'Closed Date', fieldName: 'Closed_Date__c', type: 'date' },
        { label: 'Shipping Company Owner Name', fieldName: 'ShippingCompanyOwnerName', type: 'text' },
    ];

    @wire(getRelatedOffers, { orderId: '$recordId' })
    wiredOffers({ error, data }) {
        if (data) {
            this.offers = data.map((offer) => ({
                ...offer,
               ShippingCompanyOwnerName: offer.Shipping_Company_Owner__r ? offer.Shipping_Company_Owner__r.Name : ''
            }));
        } else if (error) {
            console.error('Error fetching offers:', error);
        }
    }

    handleOpenModal() {
        console.log('pushed');
        this.isModalOpen = true;
    }

    handleCloseModal() {
        this.isModalOpen = false;
    }

    handleNext() {
       
        const selectedRows = this.template.querySelector('lightning-datatable').getSelectedRows();
        if (selectedRows.length === 0) {
            
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Warning',
                    message: 'Please select an offer to continue.',
                    variant: 'warning',
                }),
            );
            return;
        }
        this.selectedOfferId = selectedRows[0].Id;

        createContract({ offerId: this.selectedOfferId, orderId: this.recordId })
            .then(() => {
                this.handleCloseModal(); 
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Contract created successfully!',
                        variant: 'success',
                    }),
                );
            })
            .catch((error) => {
                console.error('Error creating contract:', error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Failed to create contract.',
                        variant: 'error',
                    }),
                );
            });
    }
}
