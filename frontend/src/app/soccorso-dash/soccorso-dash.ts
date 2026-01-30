import { Component, OnInit, Renderer2, ViewEncapsulation } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterModule } from '@angular/router';
import { HttpClientModule } from '@angular/common/http';
// Assicurati che il percorso sia giusto
import { TrafficService,TrafficIncident } from '../traffic.service';
import { from } from 'rxjs';

@Component({
  selector: 'app-soccorso-dash',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterModule, HttpClientModule],
  templateUrl: './soccorso-dash.html',
  styleUrl: './soccorso-dash.css',
  encapsulation: ViewEncapsulation.None
})
export class SoccorsoDash implements OnInit {

  // UI State
  isSidebarOpen: boolean = false;
  isDarkMode: boolean = false;
  acceptingSoccorsi: boolean = true;
  workshopName: string = 'Officina Centrale';
  
  // Data State
  requests: Array<any> = [];
  selectedRequest: any = null;
  
  // Traffic State
  trafficNews: TrafficIncident[] = [];
  isLoadingTraffic: boolean = false;

  // Unico Costruttore con entrambe le injection
  constructor(
    private renderer: Renderer2,
    private trafficService: TrafficService
  ) {}

  ngOnInit(): void {
    // 1. Dark Mode Check
    if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
      this.toggleDarkMode();
    }
    // 2. Caricamento Dati
    this.loadRequests();
    this.loadRealTraffic();
  }

  // --- TRAFFIC LOGIC ---
  loadRealTraffic(): void {
    this.isLoadingTraffic = true;
    this.trafficService.getRealTimeTraffic('Milano').subscribe({
      next: (data) => {
        this.trafficNews = data;
        this.isLoadingTraffic = false;
      },
      error: (e) => {
        console.error('Errore traffico', e);
        this.isLoadingTraffic = false;
      }
    });
  }

  getIconByText(text: string): string {
    const t = text.toLowerCase();
    if (t.includes('incidente') || t.includes('schianto') || t.includes('mortale')) return 'car_crash';
    if (t.includes('lavori') || t.includes('cantiere')) return 'construction';
    if (t.includes('coda') || t.includes('rallentamenti') || t.includes('traffico')) return 'traffic';
    if (t.includes('chiusa') || t.includes('blocco')) return 'no_transfer';
    return 'campaign'; 
  }

  // --- CORE LOGIC ---
  openMenu(): void { this.isSidebarOpen = true; }
  closeMenu(): void { this.isSidebarOpen = false; }

  toggleDarkMode(): void {
    this.isDarkMode = !this.isDarkMode;
    const body = document.body;
    if (this.isDarkMode) {
      this.renderer.addClass(body, 'dark-theme-variables');
    } else {
      this.renderer.removeClass(body, 'dark-theme-variables');
    }
  }

  logout(): void { console.log("Logout triggered"); }

  toggleSoccorsi(): void { this.acceptingSoccorsi = !this.acceptingSoccorsi; }

  loadRequests(): void {
    this.requests = [
      { id: 'SOS-2491', time: new Date(), vehicleType: 'Fiat Ducato (Furgone)', contact: '+39 333 1234567', status: null, lat: 45.4642, lng: 9.1900 },
      { id: 'SOS-2492', time: new Date(Date.now() - 1000 * 60 * 15), vehicleType: 'BMW X3 (SUV)', contact: '+39 338 9876543', status: 'accepted', lat: 45.4700, lng: 9.1800 },
      { id: 'SOS-2488', time: new Date(Date.now() - 1000 * 60 * 120), vehicleType: 'Smart ForTwo', contact: '+39 339 0000000', status: 'handled', lat: 45.4500, lng: 9.2000 }
    ];
    if (this.requests.length > 0) this.selectedRequest = this.requests[0];
  }

  selectRequest(req: any): void { this.selectedRequest = req; }

  acceptRequest(req: any): void { req.status = 'accepted'; }

  declineRequest(req: any): void {
    this.requests = this.requests.filter(x => x.id !== req.id);
    this.selectedRequest = this.requests[0] || null;
  }

  markHandled(req: any): void {
    req.status = 'handled';
    setTimeout(() => {
        this.requests = this.requests.filter(x => x.id !== req.id);
        if(this.selectedRequest?.id === req.id) this.selectedRequest = this.requests[0] || null;
    }, 1000);
  }
}