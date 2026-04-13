    .text
    .globl make_node
    .globl insert
    .globl get
    .globl getAtMost

# struct Node: 
# offset 0: int val (4 bytes)
# offset 4: pad (4 bytes)
# offset 8: Node* left (8 bytes)
# offset 16: Node* right (8 bytes)

# make_node(int val) -> struct Node*
make_node:
    addi sp, sp, -16
    sd ra, 8(sp)
    sd s0, 0(sp)
    mv s0, a0
    
    # malloc(24) to allocate space for node
    li a0, 24
    call malloc
    
    # if malloc fails, return NULL
    beqz a0, make_node_done
    
    # initialize node values
    sw s0, 0(a0)      # node->val = val
    sd zero, 8(a0)    # node->left = NULL
    sd zero, 16(a0)   # node->right = NULL

make_node_done:
    ld s0, 0(sp)
    ld ra, 8(sp)
    addi sp, sp, 16
    ret

# insert(struct Node* root, int val) -> struct Node*
insert:
    addi sp, sp, -32
    sd ra, 24(sp)
    sd s0, 16(sp)
    sd s1, 8(sp)
    
    mv s0, a0
    mv s1, a1
    
    # if root is not null, do recursive insert
    bnez s0, insert_notnull
    
    # root is null, make a new node
    mv a0, s1
    call make_node
    # return immediately
    j insert_done
    
insert_notnull:
    lw t0, 0(s0)       # t0 = root->val
    
    # no duplicate insertions
    beq t0, s1, insert_dup 
    
    # if val < root->val, insert in left subtree
    blt s1, t0, insert_left 
    
    # val > root->val, insert in right subtree
    ld a0, 16(s0)      # a0 = root->right
    mv a1, s1
    call insert
    sd a0, 16(s0)      # root->right = updated subtree
    mv a0, s0          # return root
    j insert_done
    
insert_left:
    ld a0, 8(s0)       # a0 = root->left
    mv a1, s1
    call insert
    sd a0, 8(s0)       # root->left = updated subtree
    mv a0, s0          # return root
    j insert_done
    
insert_dup:
    mv a0, s0          # return root unchanged without insert
    
insert_done:
    # epilogue
    ld s1, 8(sp)
    ld s0, 16(sp)
    ld ra, 24(sp)
    addi sp, sp, 32
    ret

# get(struct Node* root, int val) -> struct Node*
get:
    # a0 = root, a1 = val
get_loop:
    # if root == NULL, return NULL
    beqz a0, get_done  
    
    lw t0, 0(a0)       # load root->val
    
    # found val?
    beq t0, a1, get_done 
    
    # if val < root->val, go left
    blt a1, t0, get_left 
    
    # val > root->val, go right
    ld a0, 16(a0)
    j get_loop
    
get_left:
    ld a0, 8(a0)
    j get_loop
    
get_done:
    # return the node pointer (or NULL) in a0
    ret

# getAtMost(int val, struct Node* root) -> int
getAtMost:
    # a0 = val, a1 = root
    # initialize best known value to -1
    li t1, -1          
    
getAtMost_loop:
    # if root == NULL, break loop
    beqz a1, getAtMost_done
    
    lw t0, 0(a1)       # load current->val
    
    # if current->val > target, valid value must be in left subtree
    bgt t0, a0, getAtMost_left 
    
    # current->val <= target. It's a valid candidate.
    # is it better than our current best?
    ble t0, t1, getAtMost_right 
    mv t1, t0          # update best value
    
getAtMost_right:
    ld a1, 16(a1)      # traverse right to possibly find a larger valid value
    j getAtMost_loop
    
getAtMost_left:
    ld a1, 8(a1)       # traverse left because current node is too big
    j getAtMost_loop
    
getAtMost_done:
    mv a0, t1          # return best value
    ret