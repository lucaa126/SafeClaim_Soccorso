import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { SoccorsoData, Request } from '../soccorso-data';
import { FormsModule } from '@angular/forms';
import { ThemeService } from '../theme.service';

@Component({
  selector: 'app-richieste',
  standalone: true,
  imports: [CommonModule, RouterModule, FormsModule],
  templateUrl: './richieste.html',
  styleUrls: ['../soccorso-dash/soccorso-dash.css', './richieste.css']
})
export class Richieste implements OnInit {
  
  allRequests: Request[] = [];
  filteredRequests: Request[] = [];
  filterStatus: string = 'all'; // 'all', 'pending', 'accepted', 'handled'

  constructor(private dataService: SoccorsoData, private themeService: ThemeService) {}

  ngOnInit() {
    this.dataService.requests$.subscribe(data => {
      this.allRequests = data;
      this.applyFilter();
    });
  }

  setFilter(status: string) {
    this.filterStatus = status;
    this.applyFilter();
  }

  applyFilter() {
    if (this.filterStatus === 'all') {
      this.filteredRequests = this.allRequests;
    } else if (this.filterStatus === 'pending') {
      this.filteredRequests = this.allRequests.filter(r => !r.status);
    } else {
      this.filteredRequests = this.allRequests.filter(r => r.status === this.filterStatus);
    }
  }

  accept(req: Request) {
    // Simuliamo assegnazione automatica al primo driver disponibile
    this.dataService.updateRequestStatus(req.id, 'accepted', 'Mario Rossi (Auto)');
  }

  complete(req: Request) {
    this.dataService.updateRequestStatus(req.id, 'handled');
  }

  delete(req: Request) {
    if(confirm('Eliminare la richiesta ' + req.id + '?')) {
      this.dataService.deleteRequest(req.id);
    }
  }

  toggleDarkMode(): void {
    this.themeService.toggleDarkMode();
  }

  get isDarkMode(): boolean {
    return this.themeService.isDarkMode;
  }
}