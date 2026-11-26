/**
 * core/repositories/NodeRepository.js
 * All IndexedDB access for Node data goes through here.
 */
import { dbGet, dbGetAll, dbGetByIndex, dbPut, dbDelete } from '../database/db.js';
import { STORES } from '../database/schema.js';
import { isValidNode } from '../models/Node.js';

export const NodeRepository = {

  /** @returns {Promise<NodeModel|undefined>} */
  getById: (id) => dbGet(STORES.NODES, id),

  /** @returns {Promise<NodeModel[]>} */
  getAll: () => dbGetAll(STORES.NODES),

  /** @returns {Promise<NodeModel[]>} */
  getByStage: (stageId) => dbGetByIndex(STORES.NODES, 'by_stage', stageId),

  /** @returns {Promise<NodeModel[]>} */
  getChildren: (parentId) => dbGetByIndex(STORES.NODES, 'by_parent', parentId),

  /**
   * Get direct prerequisite nodes for a given node.
   * @param {string} nodeId
   * @returns {Promise<NodeModel[]>}
   */
  async getPrerequisites(nodeId) {
    const node = await NodeRepository.getById(nodeId);
    if (!node || !node.prerequisiteNodeIds?.length) return [];
    const results = await Promise.all(node.prerequisiteNodeIds.map(id => NodeRepository.getById(id)));
    return results.filter(Boolean);
  },

  /**
   * Get all nodes that have the given node as a prerequisite.
   */
  async getNextNodes(nodeId) {
    const node = await NodeRepository.getById(nodeId);
    if (!node || !node.nextNodeIds?.length) return [];
    const results = await Promise.all(node.nextNodeIds.map(id => NodeRepository.getById(id)));
    return results.filter(Boolean);
  },

  /** @returns {Promise<NodeModel>} */
  save: async (node) => {
    if (!isValidNode(node)) throw new Error('[NodeRepository] Invalid node: ' + JSON.stringify(node));
    node.updatedAt = Date.now();
    await dbPut(STORES.NODES, node);
    return node;
  },

  delete: (id) => dbDelete(STORES.NODES, id)
};
