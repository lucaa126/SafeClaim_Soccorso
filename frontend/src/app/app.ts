import { Component, signal } from '@angular/core';
import { SoccorsoDash } from './soccorso-dash/soccorso-dash';



@Component({
  selector: 'app-root',
  imports: [SoccorsoDash],
  templateUrl: './app.html',
  styleUrl: './app.css'
})
export class App {
  protected readonly title = signal('frontend');
}
