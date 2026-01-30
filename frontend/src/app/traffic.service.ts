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