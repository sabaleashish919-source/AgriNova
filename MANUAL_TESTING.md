# AgriNova Manual Test Checklist

## Core MVP
- [ ] Register farmer
- [ ] Login farmer
- [ ] Add crop
- [ ] Edit/delete crop
- [ ] Register consumer
- [ ] Login consumer
- [ ] Buy domestic crop
- [ ] Confirm stock decreases
- [ ] Confirm order appears for buyer and farmer

## Surplus routing
- [ ] Create 7,000 kg Tomato with default 5,000 kg demand
- [ ] Confirm surplus is 40%
- [ ] Confirm 20% threshold opens export routing
- [ ] Confirm Tomato becomes export-only
- [ ] Confirm consumer cannot buy export-only Tomato
- [ ] Register international buyer
- [ ] Confirm Tomato appears in international marketplace
- [ ] Create international offer

## Expanded platform
- [ ] Register processor / bulk / institutional buyer
- [ ] Create buyer demand
- [ ] Register FPO and create collective lot
- [ ] Register transport provider and publish route/cost
- [ ] Register storage provider and publish capacity
- [ ] Submit grievance as a normal user
- [ ] Register government monitor and review aggregate overview
- [ ] Add market price observation as government/admin
- [ ] Review market price comparison and route recommendation

## Responsive UI
- [ ] Test Chrome desktop width
- [ ] Test Chrome narrow/mobile width
- [ ] Test sidebar and mobile drawer
- [ ] Test refresh on each data section
