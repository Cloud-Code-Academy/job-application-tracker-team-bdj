import { LightningElement, track } from 'lwc'; // track is used to make the LWC dynamic whenever input is added, updated, or deleted

// Initialize constants
const SOCIAL_SECURITY_RATE     = 0.062;
const SOCIAL_SECURITY_WAGE_CAP = 176100;
const MEDICARE_RATE            = 0.0145;
const HOURS_PER_YEAR           = 2080; // 52 weeks × 40 hours
const STANDARD_DEDUCTION       = 15000; // 2025 single filer

// Array for 2025 federal income tax brackets
const TAX_BRACKETS = [
    { min:      0, max:  11925, rate: 0.10 },
    { min:  11925, max:  48475, rate: 0.12 },
    { min:  48475, max: 103350, rate: 0.22 },
    { min: 103350, max: 197300, rate: 0.24 },
    { min: 197300, max: 250525, rate: 0.32 },
    { min: 250525, max: 626350, rate: 0.35 },
    { min: 626350, max: Infinity, rate: 0.37 }
];

export default class TakeHomePayCalculator extends LightningElement {
    @track expectedPay = null;
    @track frequency   = 'yearly';
    @track grossPay    = {}; // Initialized as empty, populated when the calculate method runs
    @track deductions  = {};
    @track takeHomePay = {};
    @track hasResults  = false;

    // sets the labels and values for our "Pay Frequency" dropdown 
    frequencyOptions = [
        { label: 'Hourly', value: 'hourly' },
        { label: 'Yearly', value: 'yearly' }
    ];

    handlePayChange(event) {
        this.expectedPay = parseFloat(event.target.value); // user input is accepted as a string, so we have to cast to floating point.  Yay decimals...
        this.calculate();
    }

    handleFrequencyChange(event) {
        this.frequency = event.detail.value; // <lightning-combobox> requires that we use event.detail instead of event.target to get our eventual value
        this.calculate();
    }

    calculate() {
        if (!this.expectedPay || this.expectedPay <= 0) {
            this.hasResults = false;
            return;
        }

        // Normalize to annual gross
        const annualGross = this.frequency === 'hourly'
            ? this.expectedPay * HOURS_PER_YEAR
            : this.expectedPay;

        // Annual deduction amounts
        const federalTax      = this.calcFederalTax(annualGross);
        const socialSecurity  = Math.min(annualGross, SOCIAL_SECURITY_WAGE_CAP) * SOCIAL_SECURITY_RATE;
        const medicare        = annualGross * MEDICARE_RATE;
        const totalDeductions = federalTax + socialSecurity + medicare;
        const takeHome        = annualGross - totalDeductions;

        // Gross Pay
        this.grossPay = {
            yearly:     this.formatCurrency(annualGross),
            semiAnnual: this.formatCurrency(annualGross / 2),
            monthly:    this.formatCurrency(annualGross / 12),
            biWeekly:   this.formatCurrency(annualGross / 26)
        };

        // Deductions
        this.deductions = {
            yearly: {
                federalTax:     this.formatCurrency(federalTax),
                socialSecurity: this.formatCurrency(socialSecurity),
                medicare:       this.formatCurrency(medicare),
                total:          this.formatCurrency(totalDeductions)
            },
            semiAnnual: {
                federalTax:     this.formatCurrency(federalTax / 2),
                socialSecurity: this.formatCurrency(socialSecurity / 2),
                medicare:       this.formatCurrency(medicare / 2),
                total:          this.formatCurrency(totalDeductions / 2)
            },
            monthly: {
                federalTax:     this.formatCurrency(federalTax / 12),
                socialSecurity: this.formatCurrency(socialSecurity / 12),
                medicare:       this.formatCurrency(medicare / 12),
                total:          this.formatCurrency(totalDeductions / 12)
            },
            biWeekly: {
                federalTax:     this.formatCurrency(federalTax / 26),
                socialSecurity: this.formatCurrency(socialSecurity / 26),
                medicare:       this.formatCurrency(medicare / 26),
                total:          this.formatCurrency(totalDeductions / 26)
            }
        };

        // Take-Home Pay
        this.takeHomePay = {
            yearly:     this.formatCurrency(takeHome),
            semiAnnual: this.formatCurrency(takeHome / 2),
            monthly:    this.formatCurrency(takeHome / 12),
            biWeekly:   this.formatCurrency(takeHome / 26)
        };

        this.hasResults = true;
    }


    ///*** HELPER METHODS ***///

    calcFederalTax(grossIncome) {
        const taxableIncome = Math.max(0, grossIncome - STANDARD_DEDUCTION);
        let tax = 0;
        for (const bracket of TAX_BRACKETS) {
            if (taxableIncome <= bracket.min) break;
            const taxableInBracket = Math.min(taxableIncome, bracket.max) - bracket.min;
            tax += taxableInBracket * bracket.rate;
        }
        return tax;
    }

    formatCurrency(value) {
        const abs = Math.abs(value);
        const formatted = abs.toLocaleString('en-US', {
            style:                 'currency',
            currency:              'USD',
            minimumFractionDigits: 2,
            maximumFractionDigits: 2
        });
        return value < 0 ? `(${formatted})` : formatted;
    }
}
