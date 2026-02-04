import { Routes } from '@angular/router';
import { Richieste } from './richieste/richieste';
import { Flotta } from './flotta/flotta';
import { SoccorsoDash } from './soccorso-dash/soccorso-dash';
import { Settings } from './settings/settings';
import { Analytics } from './analytics/analytics';

export const routes: Routes = [
    { path: '', redirectTo: 'dashboard', pathMatch: 'full' },
    { path: 'dashboard', component: SoccorsoDash },
    { path: 'analytics', component: Analytics },
    { path: 'richieste', component: Richieste },
    { path: 'flotta', component: Flotta },
    { path: 'settings', component: Settings}
];
