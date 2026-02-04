import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterModule } from '@angular/router';
import { SoccorsoData } from '../soccorso-data';
import { TrafficService } from '../traffic.service';
import { AnalyticsService } from './analytics.service';
import { HttpClientModule } from '@angular/common/http';

@Component({
  selector: 'app-analytics',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterModule, HttpClientModule],
  templateUrl: './analytics.html',
  styleUrl: './analytics.css'
})
export class Analytics implements OnInit {
  // Summary
  totalRequests = 0;
  pending = 0;
  accepted = 0;
  handled = 0;

  // Fleet
  fleetAvailable = 0;
  fleetBusy = 0;
  fleetMaintenance = 0;

  // Charts
  requestsLast7Days: number[] = [];
  averageHandlingMins = 0;

  // Reviews
  reviews: any[] = [];
  avgRating = 0;

  // Traffic
  trafficNews: any[] = [];
  isLoadingTraffic = false;

  // UI: Categoria selezionata (per la colonna sinistra / dettaglio a destra)
  selectedCategory: 'overview' | 'requests' | 'pending' | 'inprogress' | 'completed' | 'operations' | 'fleet' | 'reviews' = 'overview';

  constructor(
    private data: SoccorsoData,
    private analytics: AnalyticsService,
    private trafficService: TrafficService,
    private cdr: ChangeDetectorRef
  ) {}

  selectCategory(cat: string) {
    this.selectedCategory = cat as any;
    // Aggiorna i dati al cambio di categoria
    this.computeSummaries();
  }

  applyFilters() {
    // Attualmente i filtri sono locali; ricalcola le metriche
    this.computeSummaries();
  }

  exportCsv() {
    // Stub: esportazione semplice in futuro -> implementare backend o generazione CSV
    const csv = 'category,value\nrequests,' + this.totalRequests + '\nhandled,' + this.handled;
    const blob = new Blob([csv], { type: 'text/csv' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'analytics-export.csv';
    a.click();
    URL.revokeObjectURL(url);
  }

  ngOnInit(): void {
    // Load initial computed data
    this.computeSummaries();

    // Subscribe to changes so page stays live
    (this.data.requests$ as any).subscribe(() => this.computeSummaries());
    (this.data.fleet$ as any).subscribe(() => this.computeFleet());

    this.reviews = this.analytics.getRecentReviews();
    this.avgRating = this.analytics.getAverageRating();
    this.loadTraffic();
  }

  private computeSummaries() {
    const s = this.analytics.getRequestStatusCounts();
    this.pending = s.pending;
    this.accepted = s.accepted;
    this.handled = s.handled;
    this.totalRequests = s.total;

    this.requestsLast7Days = this.analytics.getRequestsOverLastDays(7);
    this.averageHandlingMins = this.analytics.getAverageHandlingTimeMinutes();

    this.computeFleet();
    this.cdr.detectChanges();
  }

  private computeFleet() {
    const f = this.analytics.getFleetStatusCounts();
    this.fleetAvailable = f.available;
    this.fleetBusy = f.busy;
    this.fleetMaintenance = f.maintenance;
  }

  private loadTraffic() {
    this.isLoadingTraffic = true;
    this.trafficService.getRealTimeTraffic('Milano').subscribe({
      next: (data) => {
        this.trafficNews = data;
        this.isLoadingTraffic = false;
        this.cdr.detectChanges();
      },
      error: (e) => {
        console.error('Errore caricamento traffico', e);
        this.isLoadingTraffic = false;
        this.cdr.detectChanges();
      }
    });
  }

  // Helper per il rendering dei grafici (bar heights)
  getMax(arr: number[]) { return Math.max(...arr, 1); }
  percentOf(value: number, max: number) { return Math.round((value / Math.max(max, 1)) * 100); }

  // Utilities
  formatMinutes(mins: number) {
    if (mins < 60) return `${mins} min`;
    const h = Math.floor(mins / 60);
    const m = mins % 60;
    return `${h}h ${m}m`;
  }
}
