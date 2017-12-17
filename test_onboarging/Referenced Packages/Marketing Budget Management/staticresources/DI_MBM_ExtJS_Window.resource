Ext.require([
    'Ext.grid.*', 
    'Ext.data.*',
    'Ext.util.*',
    'Ext.state.*',
    'Ext.form.*'
]);
/**********************************************************************************************/
Ext.namespace('DI.MBM');
/**********************************************************************************************/        
Ext.define('MCBudget', {
	extend: 'Ext.data.Model',
	fields: [
		{name: 'campId', type: 'string'},
		{name: 'Name',  type: 'string'},
		{name: 'Type', type: 'string'},
		{name: 'Status', type: 'string'},
		{name: 'Description', type: 'string'},
		{name: 'OwnerId',  type: 'string'},             
		{name: 'OwnerName', type: 'string'}
	]
});

var tempId = 0;
var tempName = "";
	
DI.MBM.CompanyWindow = Ext.extend(Ext.window.Window, {

	campaignsStoreX : null,
	id              : 'windowID',
	initComponent   : function() {
	
		this.textFieldFilter = Ext.create('Ext.form.field.TextArea', {              
			id          : 'filterInputField',
			height      : 20,
			width       : 133,
			padding     : '0 0 0 0',
			margin      : '0 10 0 10'
		});
		
		this.buttonFilterGo = Ext.create('Ext.button.Button', { 
			text        : 'Go!',
			scope       : this,
			handler     : function() {
				var tempStore = this.gridPanel.getStore();
				tempStore.clearFilter();
				tempStore.filter('Name', this.textFieldFilter.getRawValue());                       
			}               
		});
		
		this.buttonFilterClear = Ext.create('Ext.button.Button', { 
			text        : 'Clear',
			scope       : this,
			handler     : function() {
				this.textFieldFilter.setValue('');
				var tempStore = this.gridPanel.getStore();
				tempStore.clearFilter();                        
			}
		});
	
		this.filterPanel = Ext.create('Ext.form.Panel', {
			id          : 'filterPanel',                
			padding     : '0 10 0 10',
			anchor      : '100% 20%',
			renderTo    : Ext.getBody(),
			layout      : {
				type: 'hbox',
				align: 'middle'
			},
			items       : [{
							xtype   : 'label',
							forId   : 'filterInputField',
							text    : 'Search',
							}, this.textFieldFilter, this.buttonFilterGo, this.buttonFilterClear]
		});
	
	this.gridPanelHeader = Ext.create('Ext.form.Panel', {
		id: 'gridPanelHeader',              
		padding: '0 10 5 10',
		height: 24,
		renderTo: Ext.getBody(),
		layout: {
			type: 'hbox',
			align: 'left'
		},
		items: [{
			id: 'gridPanelHeaderLabel',
			xtype: 'label',
			text: 'Campaigns',
			style: {
				fontSize: '118%',
				color: '#222222'
			}
		}]
	});
	
	this.gridPanel = Ext.create('Ext.grid.Panel', {
		store: this.campaignsStoreX,
		columns: [
			{header: 'Id', dataIndex: 'campId', hidden: true},
			{header: 'Name',
				renderer: function(value) {
					return Ext.String.format('<a style="cursor: pointer;">{1}</a>', value, value);
				}, dataIndex: 'Name', flex: 2},
			{header: 'Description', dataIndex: 'Description', flex: 1},
			{header: 'Campaign Owner', dataIndex: 'OwnerId', flex: 1, hidden: true},
			{header: 'Owner', dataIndex: 'OwnerName', flex: 1},
			{header: 'Campaign Type', dataIndex: 'Type', flex: 1}                    
		],
		padding: '0 10 0 10',
		anchor: '100% 50%',
		minHeight: 215,
		listeners: {            
			itemclick: {
				fn: function(thisz, recordz, itemz, indexz, ez, optionsz)
				{                            
					tempId = recordz.data.campId;
					tempName = recordz.data.Name; 
					
					if(tempId != 0) {                            
						selectCampaignSupport(tempId, tempName)
						myDataWindow.close();                               
					}
				}
			}
		}               
	});

	this.bottomPanel = Ext.create('Ext.form.Panel', {
		id: 'bottomPanel',
		style: 'border-style: none;',
		border: 0,
		anchor: '100% 20%',
		padding: '10 10 10 10',
		layout: {                        
			type: 'vbox',
			align: 'center'
		},
		items: [ {
			id: 'innerLabel',                   
			border: 0,
			xtype: 'label',
			text: 'Copyright ? 2012 Marketing Lucidity. All rights reserved.',
			style: 'border-top: 2px solid #D9D9D9; color: #878787; margin-top: 20px; padding-top: 0.5em; text-align: center; font-size: 0.8em; border: 0 none;'
		}]
	});
	
	Ext.apply(this, {               
			height: 400,
			width: 700,
			layout: 'anchor',                  
			items: [this.filterPanel, this.gridPanelHeader, this.gridPanel, this.bottomPanel],
			modal: true,                    
			frame: true,                                        
			border: true,
			bodyborder: true,
			title: 'Select Campaign - Marketing Campaign Budgets Edit'                  
	});
	
	DI.MBM.CompanyWindow.superclass.initComponent.call(this, arguments);
	} 
});

function showExtJSGrid(currentCampaignId) {
	MBM.Marketing_Campaigns_Edit.getCampaignsListJSON(currentCampaignId, function(result, event){
		if (event.status) {                 
			try {
				var itemsSet = eval(result);
				showGrid(itemsSet);
			}
			catch(ex) {
				alert('Exception during processing result from the server. Please try again later');
			}
		} else if (event.type === 'exception') {
			alert('Application runs in demo mode! with exception: ' + event.message);
		} else {
			alert('message: ' + event.message);
		}
	}, {escape:false});          
}

var myDataWindow;

function showGrid(dataToShow)
{     
	this.campaignsStore = Ext.create('Ext.data.Store', {
		model: 'MCBudget',
		storeId:'campaignsStore',                
		sorters: [
			{
				property: 'Name',
				direction: 'ASC'     
			}
		],
		data: {'items':dataToShow},
		proxy: {
			type: 'memory',
			reader: {
				type: 'json',
				root: 'items'
			}
		}
	});
	
	myDataWindow = new DI.MBM.CompanyWindow({campaignsStoreX:this.campaignsStore});            
	myDataWindow.show();
}
