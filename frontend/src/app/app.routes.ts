import { Routes } from '@angular/router';
import { Richieste } from './richieste/richieste';
import { Flotta } from './flotta/flotta';
import { SoccorsoDash } from './soccorso-dash/soccorso-dash';
import { Settings } from './settings/settings';

export const routes: Routes = [
    { path: '', redirectTo: 'dashboard', pathMatch: 'full' },
    { path: 'dashboard', component: SoccorsoDash },
    { path: 'richieste', component: Richieste },
    { path: 'flotta', component: Flotta },
    { path: 'settings', component: Settings}
];
