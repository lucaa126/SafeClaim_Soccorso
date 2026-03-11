import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, map } from 'rxjs';

export interface TrafficIncident {
  title: string;
  pubDate: string;
  link: string;
  source: string;
}

@Injectable({ providedIn: 'root' })
export class TrafficService {
  
  // Usiamo il convertitore pubblico RSS -> JSON (nessuna chiave richiesta)
  private rssToJsonUrl = 'https://api.rss2json.com/v1/api.json';

  constructor(private http: HttpClient) {}

  getRealTimeTraffic(city: string = 'Milano'): Observable<TrafficIncident[]> {
    
    // 1. Costruiamo la query per Google News RSS
    // Cerchiamo: "Traffico" + [Città] + "Incidente"
    const query = `traffico ${city} incidente coda`;
    const googleNewsUrl = `https://news.google.com/rss/search?q=${encodeURIComponent(query)}&hl=it&gl=IT&ceid=IT:it`;

    // 2. Chiamiamo il convertitore
    return this.http.get<any>(`${this.rssToJsonUrl}?rss_url=${encodeURIComponent(googleNewsUrl)}`).pipe(
      map(response => {
        if (!response.items) return [];

        // Prendiamo le prime 10 notizie
        return response.items.map((item: any) => ({
          title: this.cleanTitle(item.title),
          pubDate: item.pubDate,
          link: item.link,
          source: item.author || 'News Traffico'
        }));
      })
    );
  }

  // Rimuove il nome della testata giornalistica dal titolo per pulizia
  private cleanTitle(title: string): string {
    return title.split(' - ')[0]; // Es: "Incidente in A4 - MilanoToday" diventa "Incidente in A4"
  }
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

  get isDarkMode(): boolean {
    return this.themeService.isDarkMode;
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
