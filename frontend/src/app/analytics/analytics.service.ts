import { Injectable } from '@angular/core';

@Injectable({
  providedIn: 'root'
})
export class AnalyticsService {

  constructor() { }

  getRequestStatusCounts() {
    return {
      total: 1250,
      pending: 325,
      accepted: 350,
      handled: 1085
    };
  }

  getRequestsOverLastDays(days: number): number[] {
    return [120, 145, 132, 150, 110, 160, 140];
  }

  getAverageHandlingTimeMinutes() {
    return 34;
  }

  getFleetStatusCounts() {
    return {
      available: 12,
      busy: 8,
      maintenance: 3
    };
  }

  getRecentReviews() {
    return [
      { author: 'Mario R.', rating: 5, comment: 'Servizio rapidissimo.', date: new Date() },
      { author: 'Anna B.', rating: 4, comment: 'Attesa lunga ma risolto.', date: new Date() }
    ];
  }

  getAverageRating() {
    return 4.7;
  }
}