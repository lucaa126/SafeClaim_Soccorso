import { Injectable } from '@angular/core';
import { SoccorsoData, Request, Vehicle } from '../soccorso-data';

export interface Review {
  id: string;
  author: string;
  rating: number; // 1-5
  comment: string;
  date: Date;
}

@Injectable({ providedIn: 'root' })
export class AnalyticsService {
  private currentRequests: Request[] = [];
  private currentFleet: Vehicle[] = [];

  constructor(private data: SoccorsoData) {
    // Manteniamo una cache interna sottoscrivendo gli observable pubblici
    this.data.requests$.subscribe((r: Request[]) => this.currentRequests = r || []);
    this.data.fleet$.subscribe((f: Vehicle[]) => this.currentFleet = f || []);
  }

  // Conteggi per stato delle richieste
  getRequestStatusCounts() {
    const values = this.currentRequests;

    const pending = values.filter(r => !r.status).length;
    const accepted = values.filter(r => r.status === 'accepted').length;
    const handled = values.filter(r => r.status === 'handled').length;

    return { pending, accepted, handled, total: values.length };
  }

  // Conteggi per stato della flotta
  getFleetStatusCounts() {
    const values = this.currentFleet;
    const available = values.filter(v => v.status === 'available').length;
    const busy = values.filter(v => v.status === 'busy').length;
    const maintenance = values.filter(v => v.status === 'maintenance').length;
    return { available, busy, maintenance, total: values.length };
  }

  // Serie temporale di richieste per gli ultimi N giorni (mocking se necessario)
  getRequestsOverLastDays(days: number = 7) {
    const values = this.currentRequests;
    const results = new Array(days).fill(0);
    const now = Date.now();
    const dayMs = 1000 * 60 * 60 * 24;

    for (const r of values) {
      const diffDays = Math.floor((now - new Date(r.time).getTime()) / dayMs);
      if (diffDays < days) {
        results[days - diffDays - 1]++;
      }
    }

    return results; // indice 0 = day - (days-1), indice ultimo = oggi
  }

  // Tempo medio di gestione (solo handled). Calcolato come ora - request.time per mock
  getAverageHandlingTimeMinutes() {
    const values = this.currentRequests;
    const handled = values.filter(r => r.status === 'handled');
    if (handled.length === 0) return 0;

    const now = Date.now();
    const mins = handled.map(h => Math.max(1, Math.round((now - new Date(h.time).getTime()) / 60000))); // minuti
    const avg = Math.round((mins.reduce((a, b) => a + b, 0) / mins.length));
    return avg;
  }

  // Mock recensioni. Potrebbero venire da un back-end reale in futuro
  getRecentReviews(): Review[] {
    return [
      { id: 'R-1', author: 'Giulia', rating: 5, comment: 'Intervento rapido e professionale.', date: new Date(Date.now() - 1000 * 60 * 60 * 24 * 2) },
      { id: 'R-2', author: 'Marco', rating: 4, comment: 'Buon servizio, unica nota sui tempi.', date: new Date(Date.now() - 1000 * 60 * 60 * 24 * 7) },
      { id: 'R-3', author: 'Sara', rating: 3, comment: 'Meccanico gentile ma attesa lunga.', date: new Date(Date.now() - 1000 * 60 * 60 * 24 * 10) }
    ];
  }

  // Rating medio dalle recensioni mock
  getAverageRating(): number {
    const reviews = this.getRecentReviews();
    if (reviews.length === 0) return 0;
    const avg = reviews.reduce((a, b) => a + b.rating, 0) / reviews.length;
    return Math.round(avg * 10) / 10; // 1 decimal
  }
}
