export class PromptBuilder {
  private systemPrompt: string = "";
  private userPrompt: string = "";
  private safetyRules: string[] = [];
  private contextNotes: string[] = [];

  setSystemPrompt(prompt: string): PromptBuilder {
    this.systemPrompt = prompt;
    return this;
  }

  setUserPrompt(prompt: string): PromptBuilder {
    this.userPrompt = prompt;
    return this;
  }

  addSafetyRule(rule: string): PromptBuilder {
    this.safetyRules.push(rule);
    return this;
  }

  addContextNote(note: string): PromptBuilder {
    this.contextNotes.push(note);
    return this;
  }

  addPetitionCategory(categoryName: string, categoryFields: Record<string, string>): PromptBuilder {
    this.contextNotes.push(`Dilekçe Kategorisi: ${categoryName}`);
    this.contextNotes.push(`Kategoriye Özel Alanlar: ${JSON.stringify(categoryFields)}`);
    return this;
  }

  setChatHistory(messages: Array<{ role: string; content: string }>): PromptBuilder {
    this.contextNotes.push(`Önceki Sohbet Geçmişi (en eski en başta olacak şekilde):\n${messages.map(m => `[${m.role.toUpperCase()}]: ${m.content}`).join("\n")}`);
    return this;
  }

  build(): { systemPrompt: string; userPrompt: string } {
    let finalSystem = this.systemPrompt;

    if (this.contextNotes.length > 0) {
      finalSystem += `\n\n=== BAĞLAM BİLGİLERİ ===\n${this.contextNotes.join("\n")}`;
    }

    if (this.safetyRules.length > 0) {
      finalSystem += `\n\n=== GÜVENLİK KURALLARI ===\n${this.safetyRules.map((r, i) => `${i + 1}. ${r}`).join("\n")}`;
    }

    finalSystem += `\n\n=== ÖZEL TALİMAT ===
- Kullanıcıya yardımcı ol; KISA, sade ve doğrudan yanıt ver, gereksiz uzatma
- Cevabı ilk cümlede ver; giriş/kapanış kalıbı ("Harika soru", "Umarım yardımcı olmuştur") yazma
- DÜZ METİN yaz; markdown biçimi (# başlık, **kalın**, tablo, --- çizgi) ve emoji kullanma
- Yukarıda belirli bir çıktı biçimi/etiket yapısı istenmişse ona uy; istenmemişse düz paragraf yaz
- Eksik bilgi için uydurma yapma; ilgili alanı boş bırak veya atla
- TÜRKÇE KARAKTERLERİ (ğşıüöç) DOĞRU KULLAN`;

    return { systemPrompt: finalSystem, userPrompt: this.userPrompt };
  }
}
