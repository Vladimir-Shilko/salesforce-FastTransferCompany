import { LightningElement, track, wire } from 'lwc';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {getObjectInfo, getPicklistValues} from 'lightning/uiObjectInfoApi';
import { getRecord } from 'lightning/uiRecordApi';

import createFreightRequest from '@salesforce/apex/FreightRequestController.createFreightRequest';

import ACCOUNT from '@salesforce/schema/Account';
import ACCOUNT_TYPE from '@salesforce/schema/Account.Type';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';

export default class FreightRequestForm extends LightningElement {

  isLoading = false;
  isUserAuthenticated = false

  accountTypes;

  accountRecordTypeId;

  @wire(getRecord, { recordId: USER_ID, fields: [NAME_FIELD] }) 
  wiredUser({ error, data }) {
      if (data) {
        this.isUserAuthenticated = true;
      } else if (error) {
          this.isUserAuthenticated = false;
      }
  }

  @wire(getObjectInfo, {objectApiName: ACCOUNT})results
  ({error, data}){
    if(data){
      this.accountRecordTypeId = data.defaultRecordTypeId;
      this.error = undefined;
    } else if (error) {
      this.error = error;
      this.accountRecordTypeId = undefined;
    }

  }
  
  @wire(getPicklistValues, {recordTypeId : "$accountRecordTypeId", fieldApiName: ACCOUNT_TYPE})picklistResults({ error, data}){
    if(data){
        this.accountTypes = data.values;
        this.error = undefined;
      } else if (error) {
        this.error = error;
        this.accountTypes = undefined;
      }
  }

  cargoTypeOptions = [
    { label: 'Food', value: 'Food' },
    { label: 'Cars and Other Vehicles', value: 'Cars and Other Vehicles' },
    { label: 'Animals', value: 'Animals' },
    { label: 'Technics', value: 'Technics' }
  ];
  
  cityOptions = [
    { label: 'Minsk', value: 'Minsk' },
    { label: 'Vitsebsk', value: 'Vitsebsk' },
    { label: 'Grodno', value: 'Grodno' },
    { label: 'Brest', value: 'Brest' },
    { label: 'Babruysk', value: 'Babruysk' },
    { label: 'Pinsk', value: 'Pinsk' },
    { label: 'Orsha', value: 'Orsha' },
    { label: 'Mazyr', value: 'Mazyr' },
    { label: 'Salihorsk', value: 'Salihorsk' }
  ];


  fromCity;
  toCity;
  cargoType;
  date;
  accountType;

  accountTypeChange(event){
    this.accountType = event.detail.value;
  }
  fromCityChange (event){
    console.log(event);
    this.fromCity = event.detail.value;

  }
  toCityChange(event){
    this.toCity = event.detail.value;
  }

  cargoTypeChange(event){
    this.cargoType = event.detail.value;
  }
  handleDateChange(event) {
    this.date = event.target.value; 
  }

  handleSubmit(event) {
    event.preventDefault();
    const formData = new FormData(this.template.querySelector('form'));
    const data = {};

    formData.forEach((value, key) => {
      data[key] = value;
    });
    
    data['cargoType'] = this.cargoType;
    data['fromCity']= this.fromCity;
    data['toCity'] = this.toCity;
    data['date'] = this.date;
    data['accountType'] = this.accountType;

    if (data.fromCity === data.toCity) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: 'Validation Error',
          message: 'The "From" and "To" cities must be different.'+data.shippingName,
          variant: 'error'
        })
      );
      return;
    }
    this.showSpinner();
    createFreightRequest({ requestData: data })
      .then(result => {
        
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'Success',
            message: 'Freight request created successfully.',
            variant: 'success'
          })
        );
      })
      .catch(error => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'Error creating request',
            message: error.body.message,
            variant: 'error'
          })
        );
      })
      .finally(() =>{
        this.hideSpinner();
      })

      }

  
  showSpinner(){
    this.isLoading = true;
 }
  hideSpinner(){
    this.isLoading = false;
  }
}