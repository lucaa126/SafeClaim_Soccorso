import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { SoccorsoData, Vehicle } from '../soccorso-data'; // Assicurati che il percorso sia corretto
import { ThemeService } from '../theme.service';

@Component({
  selector: 'app-flotta',
  standalone: true,
  imports: [CommonModule, RouterModule], // Importiamo CommonModule per *ngFor e ngClass
  templateUrl: './flotta.html',
  styleUrl: './flotta.css',
})
export class Flotta implements OnInit {
  
  fleet: Vehicle[] = [];

  constructor(private dataService: SoccorsoData, private themeService: ThemeService) {}

  ngOnInit(): void {
    // Ci iscriviamo al service: se cambia qualcosa nella flotta, aggiorniamo la vista
    this.dataService.fleet$.subscribe((vehicles) => {
      this.fleet = vehicles;
    });
  }

  // Helper per ottenere il colore del badge in base allo stato
  getStatusColor(status: string): string {
    switch (status) {
      case 'available': return 'success';     // Verde
      case 'busy': return 'danger';           // Rosso
      case 'maintenance': return 'secondary'; // Grigio
      default: return 'primary';
    }
  }

  // Helper per tradurre lo stato in italiano
  getStatusLabel(status: string): string {
    switch (status) {
      case 'available': return 'Disponibile';
      case 'busy': return 'In Intervento';
      case 'maintenance': return 'In Manutenzione';
      default: return status;
    }
  }

  // Azione simulata per contattare l'autista
  contactDriver(driverName: string) {
    alert(`Chiamata in corso a: ${driverName}...`);
  }

  toggleDarkMode(): void {
    this.themeService.toggleDarkMode();
  }

  get isDarkMode(): boolean {
    return this.themeService.isDarkMode;
  }
}