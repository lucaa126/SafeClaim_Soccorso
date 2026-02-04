import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterModule } from '@angular/router';
import { HttpClientModule } from '@angular/common/http';

// Services
import { SoccorsoData } from '../soccorso-data';
import { AnalyticsService } from './analytics.service'; 
import { TrafficService, TrafficIncident } from '../traffic.service';

@Component({
  selector: 'app-analytics',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterModule, HttpClientModule],
  templateUrl: './analytics.html',
  styleUrl: './analytics.css'
})
export class Analytics implements OnInit {
  // Stats Generali
  totalRequests = 0;
  pending = 0;
  accepted = 0;
  handled = 0;

  // Stats Flotta (Queste mancavano e davano errore)
  fleetAvailable = 0;
  fleetBusy = 0;       
  fleetMaintenance = 0;

  // Grafici e Rating
  requestsLast7Days: number[] = [];
  averageHandlingMins = 0;
  reviews: any[] = [];
  avgRating = 0;

  // Traffico
  trafficNews: TrafficIncident[] = [];
  isLoadingTraffic = false;

  selectedCategory: any = 'overview';

  constructor(
    private data: SoccorsoData,
    private analyticsService: AnalyticsService, // Nome variabile chiaro
    private trafficService: TrafficService,
    private cdr: ChangeDetectorRef
  ) {}

  ngOnInit(): void {
    this.refreshData();
    this.loadTraffic();

    // Aggiornamento live se disponibile
    if (this.data && this.data.requests$) {
        (this.data.requests$ as any).subscribe(() => this.refreshData());
    }
  }

  refreshData() {
    // Recupero dati generali
    const s = this.analyticsService.getRequestStatusCounts();
    this.totalRequests = s.total;
    this.pending = s.pending;
    this.accepted = s.accepted;
    this.handled = s.handled;

    // Recupero dati Flotta
    const f = this.analyticsService.getFleetStatusCounts();
    this.fleetAvailable = f.available;
    this.fleetBusy = f.busy;             // Assegnazione mancante corretta
    this.fleetMaintenance = f.maintenance; // Assegnazione mancante corretta

    // Altri dati
    this.requestsLast7Days = this.analyticsService.getRequestsOverLastDays(7);
    this.averageHandlingMins = this.analyticsService.getAverageHandlingTimeMinutes();
    this.reviews = this.analyticsService.getRecentReviews();
    this.avgRating = this.analyticsService.getAverageRating();
  }

  loadTraffic() {
    this.isLoadingTraffic = true;
    this.trafficService.getRealTimeTraffic('Milano').subscribe({
      next: (data) => {
        this.trafficNews = data;
        this.isLoadingTraffic = false;
        this.cdr.detectChanges();
      },
      error: (e) => {
        console.error(e);
        this.isLoadingTraffic = false;
      }
    });
  }

  // --- Funzioni Helper richieste dall'HTML ---

  // Usata per calcolare l'altezza delle barre nel grafico
  getMax(arr: number[]): number {
    if (!arr || arr.length === 0) return 1;
    return Math.max(...arr, 1);
  }

  // Usata per le barre di progresso
  percentOf(value: number, max: number): number {
    if (!max || max === 0) return 0;
    return Math.round((value / max) * 100);
  }

  // Usata per formattare il tempo medio
  formatMinutes(mins: number): string {
    const h = Math.floor(mins / 60);
    const m = mins % 60;
    if (h === 0) return `${m} min`;
    return `${h}h ${m}m`;
  }

  getIconByText(title: string): string {
    const t = title ? title.toLowerCase() : '';
    if (t.includes('incidente')) return 'car_crash';
    if (t.includes('coda')) return 'traffic';
    return 'info';
  }

  selectCategory(cat: string) { this.selectedCategory = cat; }
  applyFilters() { this.refreshData(); }
  exportCsv() { console.log('Export...'); }
}