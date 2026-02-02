import { Component, OnInit, Renderer2, ViewEncapsulation, AfterViewInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterModule } from '@angular/router';
import { HttpClientModule } from '@angular/common/http';
import { TrafficService, TrafficIncident } from '../traffic.service';

// Importiamo Leaflet
import * as L from 'leaflet';

@Component({
  selector: 'app-soccorso-dash',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterModule, HttpClientModule],
  templateUrl: './soccorso-dash.html',
  styleUrl: './soccorso-dash.css',
  encapsulation: ViewEncapsulation.None
})
export class SoccorsoDash implements OnInit, AfterViewInit {

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

  // Map State
  private map: L.Map | undefined;
  private marker: L.Marker | undefined;

  constructor(
    private renderer: Renderer2,
    private trafficService: TrafficService,
    private cdr: ChangeDetectorRef 
  ) {}

  ngOnInit(): void {
    this.fixLeafletIcons();

    if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
       // this.toggleDarkMode(); 
    }
    
    // Caricamento Dati
    this.loadRequests();
    
    setTimeout(() => {
        this.loadRealTraffic();
    }, 0);
  }

  // --- MAP LOGIC (LEAFLET) ---
  
  ngAfterViewInit(): void {
    setTimeout(() => {
      this.initMap();
    }, 100); 
  }

  private initMap(): void {
    const mapContainer = document.getElementById('map');
    if (!mapContainer) {
        return;
    }

    if (this.map) return;

    const startLat = this.selectedRequest ? this.selectedRequest.lat : 45.4642;
    const startLng = this.selectedRequest ? this.selectedRequest.lng : 9.1900;

    this.map = L.map('map').setView([startLat, startLng], 13);

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      maxZoom: 19,
      attribution: '© OpenStreetMap'
    }).addTo(this.map);

    if (this.selectedRequest) {
      this.updateMapMarker(startLat, startLng);
    }
  }

  private updateMapMarker(lat: number, lng: number): void {
    if (!this.map) {
        this.initMap();
        if (!this.map) return;
    }

    this.map.setView([lat, lng], 14);

    if (this.marker) {
      this.marker.setLatLng([lat, lng]); 
    } else {
      this.marker = L.marker([lat, lng]).addTo(this.map); 
    }

    this.marker.bindPopup("<b>Veicolo Fermo</b><br>Intervento Richiesto").openPopup();
    
    setTimeout(() => { this.map?.invalidateSize(); }, 200);
  }

  // --- TRAFFIC LOGIC ---
  loadRealTraffic(): void {
    this.isLoadingTraffic = true;
    this.cdr.detectChanges(); 

    this.trafficService.getRealTimeTraffic('Milano').subscribe({
      next: (data) => {
        this.trafficNews = data;
        this.isLoadingTraffic = false;
        this.cdr.detectChanges(); 
      },
      error: (e) => {
        console.error('Errore traffico', e);
        this.isLoadingTraffic = false;
        this.cdr.detectChanges(); 
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
      { id: 'SOS-2492', time: new Date(Date.now() - 1000 * 60 * 15), vehicleType: 'BMW X3 (SUV)', contact: '+39 338 9876543', status: 'accepted', lat: 45.4780, lng: 9.1240 }, 
      { id: 'SOS-2488', time: new Date(Date.now() - 1000 * 60 * 120), vehicleType: 'Smart ForTwo', contact: '+39 339 0000000', status: 'handled', lat: 45.4500, lng: 9.2000 }
    ];
    
    if (this.requests.length > 0) {
        this.selectedRequest = this.requests[0];
    }
  }

  selectRequest(req: any): void { 
    this.selectedRequest = req; 
    
    if (req.lat && req.lng) {
      setTimeout(() => {
        this.updateMapMarker(req.lat, req.lng);
      }, 50);
    }
  }

  // NUOVA FUNZIONE PER APRIRE MAPS
  openNavigation(req: any): void {
    if (!req || !req.lat || !req.lng) return;
    // URL universale per aprire navigazione su qualsiasi dispositivo
    const url = `https://www.google.com/maps/dir/?api=1&destination=${req.lat},${req.lng}&travelmode=driving`;
    window.open(url, '_blank');
  }

  // MODIFICATA: Accetta e apre Maps
  acceptRequest(req: any): void { 
    req.status = 'accepted'; 
    this.openNavigation(req);
  }

  declineRequest(req: any): void {
    this.requests = this.requests.filter(x => x.id !== req.id);
    this.selectedRequest = this.requests[0] || null;
    
    if(this.selectedRequest) {
        setTimeout(() => {
             this.updateMapMarker(this.selectedRequest.lat, this.selectedRequest.lng);
        }, 50);
    }
  }

  markHandled(req: any): void {
    req.status = 'handled';
    setTimeout(() => {
        this.requests = this.requests.filter(x => x.id !== req.id);
        if(this.selectedRequest?.id === req.id) {
             this.selectedRequest = this.requests[0] || null;
             if(this.selectedRequest) {
                 this.updateMapMarker(this.selectedRequest.lat, this.selectedRequest.lng);
             }
        }
    }, 1000);
  }

  private fixLeafletIcons() {
    const iconRetinaUrl = 'assets/marker-icon-2x.png';
    const iconUrl = 'assets/marker-icon.png';
    const shadowUrl = 'assets/marker-shadow.png';
    const iconDefault = L.Icon.Default.prototype as any;
    delete iconDefault._getIconUrl;
    L.Icon.Default.mergeOptions({
      iconRetinaUrl: 'https://unpkg.com/leaflet@1.7.1/dist/images/marker-icon-2x.png',
      iconUrl: 'https://unpkg.com/leaflet@1.7.1/dist/images/marker-icon.png',
      shadowUrl: 'https://unpkg.com/leaflet@1.7.1/dist/images/marker-shadow.png',
    });
  }
}