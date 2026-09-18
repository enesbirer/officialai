import prisma from "../config/prisma";
import { Petition, Prisma } from "@prisma/client";

export class PetitionRepository {
  async create(data: Prisma.PetitionCreateInput): Promise<Petition> {
    return prisma.petition.create({ data });
  }

  async findById(id: string): Promise<Petition | null> {
    return prisma.petition.findUnique({
      where: { id },
      include: { category: true },
    });
  }

  async findByUserId(
    userId: string,
    options?: { page?: number; limit?: number }
  ): Promise<{ petitions: Petition[]; total: number }> {
    const page = options?.page || 1;
    const limit = options?.limit || 10;
    const skip = (page - 1) * limit;

    const [petitions, total] = await Promise.all([
      prisma.petition.findMany({
        where: { userId },
        include: { category: true },
        skip,
        take: limit,
        orderBy: { createdAt: "desc" },
      }),
      prisma.petition.count({ where: { userId } }),
    ]);

    return { petitions, total };
  }

  async update(id: string, data: Prisma.PetitionUpdateInput): Promise<Petition> {
    return prisma.petition.update({ where: { id }, data });
  }

  async delete(id: string): Promise<void> {
    await prisma.petition.update({ where: { id }, data: { deletedAt: new Date() } });
  }
}
